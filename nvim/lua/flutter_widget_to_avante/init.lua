local M = {}

local uv = vim.loop
local watch_timer = nil
local last_payload = nil
local watch_count = 0
local watch_limit = 5
local cached_ws_uri = nil
local job_running = false

local function trim(s)
  return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function notify(msg, level, opts)
  if opts and opts.silent then
    return
  end
  pcall(vim.notify, msg, level or vim.log.levels.INFO, {
    title = "Flutter Widget → Avante",
  })
end

local function systemlist(cmd)
  local ok, result = pcall(vim.fn.systemlist, cmd)
  if not ok then
    return nil
  end
  return result
end

local function strip_ansi(text)
  if not text then
    return ""
  end
  text = text:gsub("\r", "")
  text = text:gsub("\27%[[0-9;]*[A-Za-z]", "")
  return text
end

local function extract_ws_url(text)
  if not text or text == "" then
    return nil
  end

  text = strip_ansi(text)
  local compact = text:gsub("%s+", "")

  local ws = compact:match("(ws://[^%s]+)")
  if ws then
    ws = trim(ws)
    if not ws:match("/ws$") then
      if ws:sub(-1) == "/" then
        ws = ws .. "ws"
      else
        ws = ws .. "/ws"
      end
    end
    return ws
  end

  local http = compact:match("(http://127%.0%.0%.1:%d+/[^%s]+)")
    or compact:match("(http://%[::1%]:%d+/[^%s]+)")
    or compact:match("(http://localhost:%d+/[^%s]+)")

  if not http then
    return nil
  end

  http = trim(http)
  local ws_url = http:gsub("^http", "ws")
  if not ws_url:match("/ws$") then
    if ws_url:sub(-1) == "/" then
      ws_url = ws_url .. "ws"
    else
      ws_url = ws_url .. "/ws"
    end
  end

  return ws_url
end

local function find_vm_service_from_tmux(opts)
  if not (opts.tmux and opts.tmux.enabled) then
    return nil
  end

  if vim.fn.executable("tmux") ~= 1 then
    return nil
  end

  local panes = systemlist({ "tmux", "list-panes", "-a", "-F", "#{pane_id} #{pane_current_command} #{pane_title}" })
  if not panes then
    return nil
  end

  local pane_ids = {}
  for _, line in ipairs(panes) do
    local pane_id, cmd, title = line:match("^(%S+)%s+(%S+)%s*(.*)$")
    if pane_id then
      table.insert(pane_ids, pane_id)

      local title_match = opts.tmux.pane_title_match
      local is_flutter = cmd == "flutter"
        or cmd == "dart"
        or cmd == "dartvm"
        or (title_match and title and title:find(title_match))

      if is_flutter then
        local captured = systemlist({ "tmux", "capture-pane", "-p", "-S", "-" .. tostring(opts.tmux.pane_scan_lines), "-t", pane_id })
        local blob = captured and table.concat(captured, "\n") or ""
        local ws = extract_ws_url(blob)
        if ws then
          return ws
        end
      end
    end
  end

  for _, pane_id in ipairs(pane_ids) do
    local captured = systemlist({ "tmux", "capture-pane", "-p", "-S", "-" .. tostring(opts.tmux.pane_scan_lines), "-t", pane_id })
    local blob = captured and table.concat(captured, "\n") or ""
    local ws = extract_ws_url(blob)
    if ws then
      return ws
    end
  end

  return nil
end

-- Fallback: extract VM service URI from running process arguments
-- This works even when the tmux scrollback is flooded with exceptions
local function find_vm_service_from_process()
  local ps_output = systemlist({ "ps", "aux" })
  if not ps_output then
    return nil
  end

  -- First: find the DDS process which has --vm-service-uri pointing to the raw VM service
  -- The DDS wraps the raw VM service — we want the raw one for direct extension calls
  for _, line in ipairs(ps_output) do
    if line:match("development%-service") then
      local uri = line:match("%-%-vm%-service%-uri=(http://[%w%.%[%]/:%%=_-]+)")
      if uri then
        uri = trim(uri)
        local ws = uri:gsub("^http", "ws")
        if not ws:match("/ws$") then
          ws = ws:gsub("/$", "") .. "/ws"
        end
        return ws
      end
    end
  end

  -- Fallback: any process with --vm-service-uri
  for _, line in ipairs(ps_output) do
    local uri = line:match("%-%-vm%-service%-uri=(http://[%w%.%[%]/:%%=_-]+)")
    if uri then
      uri = trim(uri)
      local ws = uri:gsub("^http", "ws")
      if not ws:match("/ws$") then
        ws = ws:gsub("/$", "") .. "/ws"
      end
      return ws
    end
  end

  return nil
end

local function ensure_avante_open(opts)
  if not (opts.avante and opts.avante.auto_open) then
    return
  end

  pcall(function()
    vim.cmd("AvanteChatNew")
  end)
end

local function find_avante_buffer()
  local target_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      if ft == "AvanteInput" then
        return buf
      end
      if ft == "AvanteChat" or ft == "Avante" then
        target_buf = buf
      end
    end
  end
  return target_buf
end

local function avante_append(text, opts)
  ensure_avante_open(opts)

  local buf = find_avante_buffer()
  if not buf then
    notify("Avante buffer not found", vim.log.levels.WARN, opts)
    return
  end

  local lines = vim.split(text, "\n", { plain = true })
  local line_count = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, lines)
end

local function resolve_ws_uri(opts)
  if cached_ws_uri then
    return cached_ws_uri
  end
  local ws = opts.vm_service_uri
    or find_vm_service_from_tmux(opts)
    or find_vm_service_from_process()
  if ws and ws ~= "" then
    cached_ws_uri = ws
    notify("Using VM service: " .. ws, vim.log.levels.INFO, opts)
  end
  return ws
end

-- Synchronous helper for one-shot use (<leader>aw)
local function run_helper_sync(opts, cb)
  local ws = resolve_ws_uri(opts)
  if not ws or ws == "" then
    notify("VM service URI not found. Ensure 'flutter run' is active in tmux.", vim.log.levels.ERROR, opts)
    return
  end

  local cmd = { opts.python, opts.helper_script, "--ws", ws }
  local output = systemlist(cmd)
  local exit_code = vim.v.shell_error

  if exit_code == 1 then
    -- Connection error — clear cached URI so next attempt re-discovers
    cached_ws_uri = nil
    -- Check stderr for CONNECTION_REFUSED specifically
    notify("Connection failed. Flutter may have restarted. Try again (URI cache cleared).", vim.log.levels.ERROR, opts)
    return
  end

  if exit_code == 3 then
    notify(
      "No widget selected in Flutter Inspector.\n"
        .. "Open DevTools → Inspector tab, enable 'Select Widget Mode',\n"
        .. "then tap a widget on your device/emulator.",
      vim.log.levels.WARN,
      opts
    )
    return
  end

  if exit_code ~= 0 then
    notify("Widget inspector error (exit " .. exit_code .. ")", vim.log.levels.ERROR, opts)
    return
  end

  if not output then
    notify("No output from widget inspector", vim.log.levels.WARN, opts)
    return
  end

  local text = trim(table.concat(output, "\n"))
  if text ~= "" then
    cb(text)
    notify("Widget appended to Avante", vim.log.levels.INFO, opts)
  else
    notify("Widget inspector returned empty response", vim.log.levels.WARN, opts)
  end
end

-- Async helper for watch mode — runs the Python script as a job so nvim never blocks
local function run_helper_async(opts, cb)
  if job_running then return end

  local ws = resolve_ws_uri(opts)
  if not ws or ws == "" then
    notify("VM service URI not found. Ensure 'flutter run' is active in tmux.", vim.log.levels.ERROR, opts)
    return
  end

  job_running = true
  local stdout_chunks = {}
  local stderr_chunks = {}

  vim.fn.jobstart({ opts.python, opts.helper_script, "--ws", ws }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout_chunks, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stderr_chunks, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      job_running = false
      if exit_code == 1 then
        -- Connection error — clear cached URI
        cached_ws_uri = nil
        vim.schedule(function()
          notify("Connection lost. Flutter may have restarted. URI cache cleared.", vim.log.levels.ERROR, opts)
        end)
        return
      end
      if exit_code == 3 then
        -- No widget selected — silently skip in watch mode
        return
      end
      if exit_code ~= 0 then return end
      local text = trim(table.concat(stdout_chunks, "\n"))
      if text ~= "" then
        vim.schedule(function() cb(text) end)
      end
    end,
  })
end

local function start_watch(opts, limit)
  if watch_timer then
    notify("Flutter widget watch already running", vim.log.levels.INFO, opts)
    return
  end

  watch_count = 0
  watch_limit = limit or opts.watch_max_widgets or 5
  last_payload = nil

  watch_timer = uv.new_timer()
  watch_timer:start(0, opts.watch_interval, function()
    vim.schedule(function()
      -- Check limit before polling
      if watch_count >= watch_limit then
        stop_watch(opts)
        notify(
          string.format("Watch stopped: reached %d/%d widget limit", watch_count, watch_limit),
          vim.log.levels.INFO,
          opts
        )
        return
      end

      run_helper_async(opts, function(payload)
        if payload ~= last_payload then
          last_payload = payload
          watch_count = watch_count + 1
          avante_append(payload, opts)
          notify(
            string.format("Widget %d/%d appended", watch_count, watch_limit),
            vim.log.levels.INFO,
            opts
          )

          if watch_count >= watch_limit then
            stop_watch(opts)
            notify(
              string.format("Watch auto-stopped: reached %d widget limit", watch_limit),
              vim.log.levels.INFO,
              opts
            )
          end
        end
      end)
    end)
  end)

  notify(
    string.format("Flutter widget watch started (limit: %d widgets)", watch_limit),
    vim.log.levels.INFO,
    opts
  )
end

local function stop_watch(opts)
  if watch_timer then
    watch_timer:stop()
    watch_timer:close()
    watch_timer = nil
    notify("Flutter widget watch stopped", vim.log.levels.INFO, opts)
  end
end

function M.setup(opts)
  opts = opts or {}
  opts.tmux = opts.tmux or { enabled = true, pane_scan_lines = 100000, pane_title_match = "flutter" }
  opts.avante = opts.avante or { auto_open = true, auto_submit = false }
  opts.keymaps = opts.keymaps or {}
  opts.watch_interval = opts.watch_interval or 500
  opts.watch_max_widgets = opts.watch_max_widgets or 5
  opts.python = opts.python or "python3"
  opts.helper_script = opts.helper_script or vim.fn.expand("~/.config/nvim/scripts/flutter_widget_inspector.py")

  -- One-shot: append selected widget to Avante
  vim.api.nvim_create_user_command("FlutterWidgetToAvante", function()
    run_helper_sync(opts, function(text)
      avante_append(text, opts)
    end)
  end, {})

  -- Start watch with default limit
  vim.api.nvim_create_user_command("FlutterWidgetWatchStart", function(cmd_opts)
    local limit = tonumber(cmd_opts.args) or opts.watch_max_widgets
    start_watch(opts, limit)
  end, { nargs = "?" })

  -- Stop watch
  vim.api.nvim_create_user_command("FlutterWidgetWatchStop", function()
    stop_watch(opts)
  end, {})

  -- Prompt for custom limit then start watch
  vim.api.nvim_create_user_command("FlutterWidgetWatchPrompt", function()
    vim.ui.input({ prompt = "Max widgets to capture: ", default = tostring(opts.watch_max_widgets) }, function(input)
      if not input or input == "" then return end
      local limit = tonumber(input)
      if not limit or limit < 1 then
        notify("Invalid number", vim.log.levels.ERROR, opts)
        return
      end
      start_watch(opts, limit)
    end)
  end, {})

  -- Clear cached VM service URI (useful if flutter restarted)
  vim.api.nvim_create_user_command("FlutterWidgetResetUri", function()
    cached_ws_uri = nil
    notify("VM service URI cache cleared", vim.log.levels.INFO, opts)
  end, {})

  -- Keymaps
  if opts.keymaps.append then
    vim.keymap.set("n", opts.keymaps.append, "<cmd>FlutterWidgetToAvante<cr>", { desc = "Append Flutter widget to Avante" })
  end

  if opts.keymaps.watch_start then
    vim.keymap.set("n", opts.keymaps.watch_start, "<cmd>FlutterWidgetWatchStart<cr>", { desc = "Start Flutter widget watch (limit: " .. opts.watch_max_widgets .. ")" })
  end

  if opts.keymaps.watch_stop then
    vim.keymap.set("n", opts.keymaps.watch_stop, "<cmd>FlutterWidgetWatchStop<cr>", { desc = "Stop Flutter widget watch" })
  end

  if opts.keymaps.watch_prompt then
    vim.keymap.set("n", opts.keymaps.watch_prompt, "<cmd>FlutterWidgetWatchPrompt<cr>", { desc = "Start Flutter widget watch with custom limit" })
  end
end

return M
