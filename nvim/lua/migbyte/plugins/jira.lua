-- ============================================================
--  jira.lua — Ticket -> Feature Pipeline for Flutter + Neovim
--  Integrates: Jira API -> Telescope -> Avante -> TDD -> LazyGit
--
--  Multi-project support: SCRUM, CARSELL, SW, RC, STSTORE,
--  FLEET, CARAUC, BAC, FAZAA, COLLAB
--
--  Lazy.nvim plugin spec that also loads kid-icarus/jira.nvim
--  for the base :Jira commands + Telescope/Snacks pickers.
-- ============================================================

-- ─── PIPELINE MODULE (lives alongside the plugin spec) ─────
local pipeline = {}

-- ─── NOTIFICATION HELPER ───────────────────────────────────
-- Routes through nvim-notify (loaded by avante.lua / noice.lua)
local function notify(msg, level)
  level = level or vim.log.levels.INFO
  local ok, nvim_notify = pcall(require, "notify")
  if ok then
    nvim_notify(msg, level, { title = "Jira Pipeline" })
  else
    vim.notify("[Jira] " .. msg, level)
  end
end

-- ─── SAFE FIELD ACCESS (vim.NIL guard) ─────────────────────
-- Jira API returns JSON null which vim.fn.json_decode converts to
-- vim.NIL (a userdata value), NOT Lua nil.  Indexing vim.NIL crashes
-- with "attempt to index userdata value".  This helper turns vim.NIL
-- into real nil so normal `and`/`or` guards work.
local function safe(val)
  if val == nil or val == vim.NIL then return nil end
  return val
end

--- Safely access a nested field: safe_field(f, "assignee", "displayName")
local function safe_field(tbl, ...)
  local v = tbl
  for _, key in ipairs({ ... }) do
    v = safe(v)
    if v == nil or type(v) ~= "table" then return nil end
    v = v[key]
  end
  return safe(v)
end

-- ─── CONFIG ────────────────────────────────────────────────
local function get_env(key, fallback)
  local val = vim.fn.getenv(key)
  if val == vim.NIL or val == "" then
    if fallback then return fallback end
    notify("Missing env var: " .. key, vim.log.levels.ERROR)
    return nil
  end
  return val
end

local cfg = {
  base_url = function() return get_env("JIRA_BASE_URL", "https://sayaratech.atlassian.net") end,
  email    = function() return get_env("JIRA_EMAIL", "migdad@sayaratech.com") end,
  token    = function() return get_env("JIRA_API_TOKEN") end,
}

-- All known project keys (used as fallback if API fetch fails)
local ALL_PROJECTS = {
  "SCRUM", "CARSELL", "SW", "RC", "STSTORE",
  "FLEET", "CARAUC", "BAC", "FAZAA", "COLLAB",
}

-- Cached projects list from API (populated on first use)
local cached_projects = nil

-- ─── STATE ─────────────────────────────────────────────────
local state = {
  active_ticket = nil, -- { key, summary, description }
  timer_start   = nil, -- os.time() when session began
  timer_handle  = nil, -- uv timer for statusline refresh
}

-- ─── HELPERS ───────────────────────────────────────────────

local function base64_encode(data)
  local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  return ((data:gsub(".", function(x)
    local r, byte = "", x:byte()
    for i = 8, 1, -1 do
      r = r .. (byte % 2 ^ i - byte % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return r
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    if #x < 6 then return "" end
    local c = 0
    for i = 1, 6 do c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0) end
    return b:sub(c + 1, c + 1)
  end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

local function auth_header()
  local email = cfg.email()
  local token = cfg.token()
  if not email or not token then return nil end
  return "Basic " .. base64_encode(email .. ":" .. token)
end

local function elapsed_seconds()
  if not state.timer_start then return 0 end
  return os.time() - state.timer_start
end

local function format_elapsed()
  local s = elapsed_seconds()
  return string.format("%dh %02dm", math.floor(s / 3600), math.floor((s % 3600) / 60))
end

-- ─── JIRA REST API (curl, zero deps) ──────────────────────

local function jira_request(method, path, body, callback)
  local base = cfg.base_url()
  local auth = auth_header()
  if not base or not auth then return end

  local url = base .. "/rest/api/3" .. path
  local cmd = {
    "curl", "-s", "-w", "\n%{http_code}", "-X", method,
    "-H", "Authorization: " .. auth,
    "-H", "Content-Type: application/json",
    "-H", "Accept: application/json",
  }
  if body then
    table.insert(cmd, "-d")
    table.insert(cmd, vim.fn.json_encode(body))
  end
  table.insert(cmd, url)

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data or not data[1] or data[1] == "" then return end
      vim.schedule(function()
        local raw = table.concat(data, "\n")
        local lines = vim.split(raw, "\n")
        local http_code = nil
        local body_lines = {}
        for i = #lines, 1, -1 do
          if lines[i]:match("^%d+$") and not http_code then
            http_code = tonumber(lines[i])
          else
            table.insert(body_lines, 1, lines[i])
          end
        end
        local body_str = table.concat(body_lines, "\n")

        if http_code and http_code >= 400 then
          local err_msg = string.format("HTTP %d: %s", http_code, body_str:sub(1, 300))
          callback(err_msg, nil)
          return
        end

        if body_str == "" then
          callback(nil, {})
          return
        end

        local ok, decoded = pcall(vim.fn.json_decode, body_str)
        if ok then
          if decoded.errorMessages and #decoded.errorMessages > 0 then
            callback("Jira API: " .. table.concat(decoded.errorMessages, ", "), decoded)
          elseif decoded.errors and next(decoded.errors) then
            local errs = {}
            for k, v in pairs(decoded.errors) do
              table.insert(errs, k .. ": " .. v)
            end
            callback("Jira API: " .. table.concat(errs, ", "), decoded)
          else
            callback(nil, decoded)
          end
        else
          callback("JSON parse error: " .. body_str:sub(1, 200), nil)
        end
      end)
    end,
    on_stderr = function(_, data)
      if data and data[1] ~= "" then
        local msg = table.concat(data, "")
        if msg:match("%S") then
          vim.schedule(function() callback("curl error: " .. msg, nil) end)
        end
      end
    end,
  })
end

-- ─── PROJECT MANAGEMENT ───────────────────────────────────

--- Fetch all projects from Jira API and cache them
local function fetch_projects(callback)
  if cached_projects then
    callback(cached_projects)
    return
  end

  jira_request("GET", "/project?recent=50", nil, function(err, data)
    if err or type(data) ~= "table" then
      notify("Could not fetch projects, using fallback list", vim.log.levels.WARN)
      cached_projects = {}
      for _, key in ipairs(ALL_PROJECTS) do
        table.insert(cached_projects, { key = key, name = key })
      end
      callback(cached_projects)
      return
    end

    cached_projects = {}
    for _, p in ipairs(data) do
      table.insert(cached_projects, { key = p.key, name = p.name })
    end

    if #cached_projects == 0 then
      for _, key in ipairs(ALL_PROJECTS) do
        table.insert(cached_projects, { key = key, name = key })
      end
    end

    callback(cached_projects)
  end)
end

--- Show a Telescope picker to select a project, then call callback with the project
local function pick_project(prompt_title, callback)
  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  fetch_projects(function(projects)
    pickers.new({}, {
      prompt_title = prompt_title or "Select Jira Project",
      finder = finders.new_table({
        results = projects,
        entry_maker = function(project)
          local label = string.format("[%s] %s", project.key, project.name)
          return { value = project, display = label, ordinal = label }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          callback(entry.value)
        end)
        return true
      end,
    }):find()
  end)
end

-- ─── TICKET FETCHING ──────────────────────────────────────

--- Fetch tickets across ALL projects (or a specific project)
local function fetch_tickets(opts, callback)
  opts = opts or {}
  local project_key = opts.project_key -- nil = all projects

  local jql
  if project_key then
    jql = string.format(
      "project=%s AND assignee=currentUser() AND statusCategory != Done ORDER BY updated DESC",
      project_key
    )
  else
    -- Fetch across all known projects
    fetch_projects(function(projects)
      local keys = {}
      for _, p in ipairs(projects) do
        table.insert(keys, p.key)
      end
      jql = string.format(
        "project IN (%s) AND assignee=currentUser() AND statusCategory != Done ORDER BY updated DESC",
        table.concat(keys, ",")
      )
      local path = "/search/jql?jql=" .. vim.uri_encode(jql)
        .. "&maxResults=50"
        .. "&fields=summary,description,status,priority,customfield_10016,issuetype,parent,subtasks,issuelinks,comment"
      jira_request("GET", path, nil, callback)
    end)
    return
  end

  local path = "/search/jql?jql=" .. vim.uri_encode(jql)
    .. "&maxResults=50"
    .. "&fields=summary,description,status,priority,customfield_10016,issuetype,parent,subtasks,issuelinks,comment"
  jira_request("GET", path, nil, callback)
end

--- Post a worklog entry
local function post_worklog(ticket_key, seconds, callback)
  local body = {
    timeSpentSeconds = seconds,
    comment = {
      type = "doc", version = 1,
      content = { {
        type = "paragraph",
        content = { { type = "text", text = "Logged from Neovim Jira Pipeline" } },
      } },
    },
  }
  jira_request("POST", "/issue/" .. ticket_key .. "/worklog", body, callback or function() end)
end

--- Add a comment to a ticket
local function add_comment(ticket_key, text)
  local body = {
    body = {
      type = "doc", version = 1,
      content = { {
        type = "paragraph",
        content = { { type = "text", text = text } },
      } },
    },
  }
  jira_request("POST", "/issue/" .. ticket_key .. "/comment", body, function() end)
end

-- ─── TRANSITIONS ──────────────────────────────────────────

--- Fetch available transitions for a ticket, then show a picker
local function transition_picker(ticket_key, callback)
  jira_request("GET", "/issue/" .. ticket_key .. "/transitions", nil, function(err, data)
    if err or not data then
      notify("Failed to fetch transitions: " .. (err or "unknown"), vim.log.levels.ERROR)
      return
    end

    local transitions = data.transitions or {}
    if #transitions == 0 then
      notify("No transitions available for " .. ticket_key, vim.log.levels.WARN)
      return
    end

    local names = {}
    local id_map = {}
    for _, t in ipairs(transitions) do
      table.insert(names, t.name)
      id_map[t.name] = t.id
    end

    vim.ui.select(names, { prompt = "Transition " .. ticket_key .. " to:" }, function(choice)
      if not choice then return end
      jira_request("POST", "/issue/" .. ticket_key .. "/transitions", {
        transition = { id = id_map[choice] },
      }, function(terr)
        if terr then
          notify("Transition failed: " .. tostring(terr), vim.log.levels.ERROR)
        else
          notify(ticket_key .. " -> " .. choice)
          if callback then callback(choice) end
        end
      end)
    end)
  end)
end

--- Transition a ticket to a status by name (non-interactive, for automation)
local function transition_ticket(ticket_key, status_name, callback)
  jira_request("GET", "/issue/" .. ticket_key .. "/transitions", nil, function(err, data)
    if err or not data then
      notify("Transition fetch failed: " .. (err or "unknown"), vim.log.levels.ERROR)
      return
    end
    for _, t in ipairs(data.transitions or {}) do
      if t.name:lower():find(status_name:lower()) then
        jira_request("POST", "/issue/" .. ticket_key .. "/transitions", {
          transition = { id = t.id },
        }, callback or function() end)
        return
      end
    end
    notify("No transition matching: " .. status_name, vim.log.levels.WARN)
  end)
end

-- ─── ADF -> PLAIN TEXT / MARKDOWN ─────────────────────────

local function adf_to_text(node, depth)
  if not node or node == vim.NIL then return "" end
  if type(node) == "string" then return node end
  depth = depth or 0
  local result = {}

  if node.type == "text" then
    local text = node.text or ""
    -- Apply marks (bold, italic, code, etc.)
    if node.marks then
      for _, mark in ipairs(node.marks) do
        if mark.type == "strong" then
          text = "**" .. text .. "**"
        elseif mark.type == "em" then
          text = "_" .. text .. "_"
        elseif mark.type == "code" then
          text = "`" .. text .. "`"
        elseif mark.type == "link" and mark.attrs and mark.attrs.href then
          text = "[" .. text .. "](" .. mark.attrs.href .. ")"
        end
      end
    end
    return text
  elseif node.type == "hardBreak" then
    return "\n"
  elseif node.type == "heading" then
    local level = node.attrs and node.attrs.level or 1
    local prefix = string.rep("#", level) .. " "
    for _, child in ipairs(node.content or {}) do
      table.insert(result, adf_to_text(child, depth))
    end
    return prefix .. table.concat(result, "") .. "\n"
  elseif node.type == "paragraph" then
    for _, child in ipairs(node.content or {}) do
      table.insert(result, adf_to_text(child, depth))
    end
    return table.concat(result, "") .. "\n"
  elseif node.type == "bulletList" then
    for _, child in ipairs(node.content or {}) do
      table.insert(result, adf_to_text(child, depth + 1))
    end
    return table.concat(result, "")
  elseif node.type == "orderedList" then
    local idx = 1
    for _, child in ipairs(node.content or {}) do
      -- orderedList children are listItems
      local indent = string.rep("  ", depth)
      for _, grandchild in ipairs(child.content or {}) do
        local text = adf_to_text(grandchild, depth + 1)
        table.insert(result, indent .. tostring(idx) .. ". " .. text)
      end
      idx = idx + 1
    end
    return table.concat(result, "")
  elseif node.type == "listItem" then
    local indent = string.rep("  ", depth - 1)
    for _, child in ipairs(node.content or {}) do
      local text = adf_to_text(child, depth)
      table.insert(result, indent .. "- " .. text)
    end
    return table.concat(result, "")
  elseif node.type == "codeBlock" then
    local lang = (node.attrs and node.attrs.language) or ""
    local lines = {}
    for _, child in ipairs(node.content or {}) do
      table.insert(lines, adf_to_text(child, depth))
    end
    return "```" .. lang .. "\n" .. table.concat(lines, "") .. "```\n"
  elseif node.type == "blockquote" then
    for _, child in ipairs(node.content or {}) do
      local text = adf_to_text(child, depth)
      for _, line in ipairs(vim.split(text, "\n")) do
        if line ~= "" then
          table.insert(result, "> " .. line)
        end
      end
    end
    return table.concat(result, "\n") .. "\n"
  elseif node.type == "table" then
    for _, child in ipairs(node.content or {}) do
      table.insert(result, adf_to_text(child, depth))
    end
    return table.concat(result, "")
  elseif node.type == "tableRow" then
    local cells = {}
    for _, child in ipairs(node.content or {}) do
      table.insert(cells, adf_to_text(child, depth))
    end
    return "| " .. table.concat(cells, " | ") .. " |\n"
  elseif node.type == "tableHeader" or node.type == "tableCell" then
    for _, child in ipairs(node.content or {}) do
      table.insert(result, adf_to_text(child, depth))
    end
    return vim.trim(table.concat(result, ""))
  elseif node.type == "mention" then
    return "@" .. (node.attrs and node.attrs.text or "unknown")
  elseif node.type == "emoji" then
    return node.attrs and node.attrs.shortName or ""
  elseif node.type == "mediaGroup" or node.type == "mediaSingle" then
    return "[attachment]\n"
  elseif node.type == "rule" then
    return "\n---\n"
  else
    -- Generic fallback: recurse into children
    for _, child in ipairs(node.content or {}) do
      table.insert(result, adf_to_text(child, depth))
    end
    return table.concat(result, "")
  end
end

local function extract_description(description)
  if not description or description == vim.NIL then return "No description provided." end
  return adf_to_text(description)
end

-- ─── PICK TICKET THEN DO X (reusable Telescope pattern) ───
--- Opens a Telescope picker of all tickets, then calls callback(issue)
--- with the full issue object.  Every <leader>j* command uses this so
--- the user never has to type an issue key manually.
local function pick_ticket_then(prompt_title, callback)
  local ok_t = pcall(require, "telescope")
  if not ok_t then
    notify("telescope.nvim not found", vim.log.levels.ERROR)
    return
  end

  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  notify("Fetching tickets...")
  fetch_tickets({}, function(err, data)
    if err then
      notify("Fetch failed: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    local issues = data and data.issues or {}
    if #issues == 0 then
      notify("No tickets found", vim.log.levels.WARN)
      return
    end

    pickers.new({}, {
      prompt_title = prompt_title or "Select Jira Ticket",
      finder = finders.new_table({
        results = issues,
        entry_maker = function(issue)
          local f = issue.fields
          local status_name = safe_field(f, "status", "name") or "?"
          local itype       = safe_field(f, "issuetype", "name") or "?"
          local points      = safe(f.customfield_10016) or "-"
          local label = string.format(
            "[%s] [%s] [%s] [%ssp] %s",
            issue.key, status_name, itype, tostring(points), f.summary or ""
          )
          return { value = issue, display = label, ordinal = label }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = require("telescope.previewers").new_buffer_previewer({
        title = "Ticket Details",
        define_preview = function(self, entry)
          local issue = entry.value
          local f = issue.fields
          local desc = extract_description(safe(f.description))

          local preview_lines = {
            "KEY:      " .. issue.key,
            "SUMMARY:  " .. (f.summary or ""),
            "STATUS:   " .. (safe_field(f, "status", "name") or "?"),
            "TYPE:     " .. (safe_field(f, "issuetype", "name") or "?"),
            "PRIORITY: " .. (safe_field(f, "priority", "name") or "?"),
            "POINTS:   " .. tostring(safe(f.customfield_10016) or "?"),
            "",
            "--- DESCRIPTION ---",
            "",
          }
          for _, line in ipairs(vim.split(desc, "\n")) do
            table.insert(preview_lines, line)
          end

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
        end,
      }),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          if entry then callback(entry.value) end
        end)
        return true
      end,
    }):find()
  end)
end

-- ─── MARKDOWN -> ADF (for syncing edits back to Jira) ─────

--- Parse inline markdown text into ADF inline nodes
--- Handles: **bold**, _italic_, `code`, [text](url)
local function parse_inline(text)
  local nodes = {}
  local pos = 1
  local len = #text

  while pos <= len do
    -- **bold**
    local bs, be, bold_content = text:find("%*%*(.-)%*%*", pos)
    -- _italic_ (not inside a word: preceded by space/start, followed by space/end)
    local is, ie, italic_content = text:find("_(.-)_", pos)
    -- `code`
    local cs, ce, code_content = text:find("`(.-)`", pos)
    -- [text](url)
    local ls, le, link_text, link_url = text:find("%[(.-)%]%((.-)%)", pos)

    -- Find which match comes first
    local first_start = len + 1
    local match_type = nil

    if bs and bs < first_start then first_start = bs; match_type = "bold" end
    if is and is < first_start then first_start = is; match_type = "italic" end
    if cs and cs < first_start then first_start = cs; match_type = "code" end
    if ls and ls < first_start then first_start = ls; match_type = "link" end

    if not match_type then
      -- No more inline formatting, emit rest as plain text
      local rest = text:sub(pos)
      if rest ~= "" then
        table.insert(nodes, { type = "text", text = rest })
      end
      break
    end

    -- Emit plain text before the match
    if first_start > pos then
      table.insert(nodes, { type = "text", text = text:sub(pos, first_start - 1) })
    end

    if match_type == "bold" then
      table.insert(nodes, {
        type = "text", text = bold_content,
        marks = { { type = "strong" } },
      })
      pos = be + 1
    elseif match_type == "italic" then
      table.insert(nodes, {
        type = "text", text = italic_content,
        marks = { { type = "em" } },
      })
      pos = ie + 1
    elseif match_type == "code" then
      table.insert(nodes, {
        type = "text", text = code_content,
        marks = { { type = "code" } },
      })
      pos = ce + 1
    elseif match_type == "link" then
      table.insert(nodes, {
        type = "text", text = link_text,
        marks = { { type = "link", attrs = { href = link_url } } },
      })
      pos = le + 1
    end
  end

  if #nodes == 0 then
    return { { type = "text", text = "" } }
  end
  return nodes
end

--- Convert a markdown string into Jira ADF (Atlassian Document Format)
local function markdown_to_adf(md_text)
  local lines = vim.split(md_text, "\n")
  local doc_content = {}
  local i = 1

  -- Helper: flush a list of bullet items into a bulletList node
  local function flush_bullet_list(items)
    local list_node = { type = "bulletList", content = {} }
    for _, item_text in ipairs(items) do
      table.insert(list_node.content, {
        type = "listItem",
        content = { { type = "paragraph", content = parse_inline(item_text) } },
      })
    end
    return list_node
  end

  -- Helper: flush a list of ordered items into an orderedList node
  local function flush_ordered_list(items)
    local list_node = { type = "orderedList", content = {} }
    for _, item_text in ipairs(items) do
      table.insert(list_node.content, {
        type = "listItem",
        content = { { type = "paragraph", content = parse_inline(item_text) } },
      })
    end
    return list_node
  end

  while i <= #lines do
    local line = lines[i]

    -- Heading: # ## ### etc
    local heading_level, heading_text = line:match("^(#+)%s+(.*)")
    if heading_level then
      table.insert(doc_content, {
        type = "heading",
        attrs = { level = math.min(#heading_level, 6) },
        content = parse_inline(heading_text),
      })
      i = i + 1

    -- Code block: ```lang ... ```
    elseif line:match("^```") then
      local lang = line:match("^```(%S*)")
      local code_lines = {}
      i = i + 1
      while i <= #lines and not lines[i]:match("^```") do
        table.insert(code_lines, lines[i])
        i = i + 1
      end
      i = i + 1 -- skip closing ```
      local attrs = {}
      if lang and lang ~= "" then attrs.language = lang end
      table.insert(doc_content, {
        type = "codeBlock",
        attrs = attrs,
        content = { { type = "text", text = table.concat(code_lines, "\n") } },
      })

    -- Horizontal rule: ---
    elseif line:match("^%-%-%-+%s*$") then
      table.insert(doc_content, { type = "rule" })
      i = i + 1

    -- Blockquote: > text
    elseif line:match("^>%s?") then
      local quote_lines = {}
      while i <= #lines and lines[i]:match("^>%s?") do
        table.insert(quote_lines, lines[i]:gsub("^>%s?", ""))
        i = i + 1
      end
      -- Parse quote content as paragraphs
      local quote_content = {}
      for _, ql in ipairs(quote_lines) do
        table.insert(quote_content, {
          type = "paragraph",
          content = parse_inline(ql),
        })
      end
      table.insert(doc_content, { type = "blockquote", content = quote_content })

    -- Bullet list: - item or * item
    elseif line:match("^%s*[%-*]%s+") then
      local items = {}
      while i <= #lines and lines[i]:match("^%s*[%-*]%s+") do
        local item_text = lines[i]:gsub("^%s*[%-*]%s+", "")
        table.insert(items, item_text)
        i = i + 1
      end
      table.insert(doc_content, flush_bullet_list(items))

    -- Ordered list: 1. item
    elseif line:match("^%s*%d+%.%s+") then
      local items = {}
      while i <= #lines and lines[i]:match("^%s*%d+%.%s+") do
        local item_text = lines[i]:gsub("^%s*%d+%.%s+", "")
        table.insert(items, item_text)
        i = i + 1
      end
      table.insert(doc_content, flush_ordered_list(items))

    -- Empty line: skip (don't create empty paragraphs)
    elseif line:match("^%s*$") then
      i = i + 1

    -- Regular paragraph
    else
      -- Collect consecutive non-special lines into one paragraph
      local para_parts = {}
      while i <= #lines
        and not lines[i]:match("^#")
        and not lines[i]:match("^```")
        and not lines[i]:match("^%-%-%-+%s*$")
        and not lines[i]:match("^>%s?")
        and not lines[i]:match("^%s*[%-*]%s+")
        and not lines[i]:match("^%s*%d+%.%s+")
        and not lines[i]:match("^%s*$")
      do
        table.insert(para_parts, lines[i])
        i = i + 1
      end
      local para_text = table.concat(para_parts, " ")
      table.insert(doc_content, {
        type = "paragraph",
        content = parse_inline(para_text),
      })
    end
  end

  return {
    type = "doc",
    version = 1,
    content = doc_content,
  }
end

-- ─── EDITABLE ISSUE BUFFER ───────────────────────────────

--- Save the current jira:// buffer back to Jira
local function save_issue_buffer(buf, issue_key)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- Line 1 must be "# Summary text"
  local summary_line = lines[1] or ""
  local summary = summary_line:gsub("^#%s+", "")
  if summary == "" then
    notify("First line must be: # Issue Summary", vim.log.levels.ERROR)
    return
  end

  -- Find the comments separator (read-only zone)
  local desc_end = #lines
  for idx, line in ipairs(lines) do
    if line:match("^<!%-%- COMMENTS %(read%-only%)") then
      desc_end = idx - 1
      break
    end
  end

  -- Skip the summary line and the blank line after it
  local desc_start = 2
  if lines[2] and lines[2]:match("^%s*$") then
    desc_start = 3
  end

  -- Build description markdown from lines between summary and comments
  local desc_lines = {}
  for idx = desc_start, desc_end do
    table.insert(desc_lines, lines[idx])
  end
  -- Trim trailing empty lines
  while #desc_lines > 0 and desc_lines[#desc_lines]:match("^%s*$") do
    table.remove(desc_lines)
  end

  local desc_md = table.concat(desc_lines, "\n")
  local adf = markdown_to_adf(desc_md)

  notify("Saving " .. issue_key .. " to Jira...")

  local body = {
    fields = {
      summary = summary,
      description = adf,
    },
  }

  jira_request("PUT", "/issue/" .. issue_key, body, function(err)
    if err then
      notify("Save failed: " .. tostring(err), vim.log.levels.ERROR)
    else
      notify(issue_key .. " saved to Jira")
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.bo[buf].modified = false
        end
      end)
    end
  end)
end

--- Fetch an issue and open it in an editable buffer (new tab)
function pipeline.edit_issue(issue_key)
  if not issue_key then
    if state.active_ticket then
      issue_key = state.active_ticket.key
    else
      -- No active ticket: open Telescope picker first
      pick_ticket_then("Edit Issue - Select Ticket", function(issue)
        pipeline.edit_issue(issue.key)
      end)
      return
    end
  end

  notify("Fetching " .. issue_key .. " for editing...")

  local path = "/issue/" .. issue_key
    .. "?fields=summary,description,status,issuetype,priority,comment"

  jira_request("GET", path, nil, function(err, data)
    if err then
      notify("Failed to fetch issue: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if not data or not data.fields then
      notify("Invalid issue response", vim.log.levels.ERROR)
      return
    end

    local f = data.fields
    local key = data.key

    -- Build the editable buffer content
    local lines = {}

    -- Line 1: summary as markdown heading
    table.insert(lines, "# " .. (f.summary or ""))
    table.insert(lines, "")

    -- Description converted to markdown
    local desc = extract_description(safe(f.description))
    for _, line in ipairs(vim.split(desc, "\n")) do
      table.insert(lines, line)
    end

    -- Trim trailing blank lines from description
    while #lines > 2 and lines[#lines]:match("^%s*$") do
      table.remove(lines)
    end

    table.insert(lines, "")

    -- Comments section (read-only reference)
    table.insert(lines, "<!-- COMMENTS (read-only) — everything below this line is not saved -->")
    table.insert(lines, "")

    local comments = (safe(f.comment) and safe(f.comment.comments)) or {}
    if #comments == 0 then
      table.insert(lines, "> _No comments_")
    else
      for _, comment in ipairs(comments) do
        local author = safe_field(comment, "author", "displayName") or "Unknown"
        local timestamp = (safe(comment.updated) or safe(comment.created) or "?"):sub(1, 16):gsub("T", " ")
        table.insert(lines, string.format("> **%s** _%s_", author, timestamp))
        table.insert(lines, ">")
        local body = adf_to_text(safe(comment.body))
        for _, cline in ipairs(vim.split(body, "\n")) do
          table.insert(lines, "> " .. cline)
        end
        table.insert(lines, "")
      end
    end

    -- Metadata as a comment at the end for reference
    table.insert(lines, string.format(
      "<!-- Status: %s | Type: %s | Priority: %s -->",
      safe_field(f, "status", "name") or "?",
      safe_field(f, "issuetype", "name") or "?",
      safe_field(f, "priority", "name") or "?"
    ))

    -- Open in a new tab with a jira:// buffer name
    local buf_name = "jira://" .. key
    -- Check if a buffer with this name already exists
    local existing_buf = nil
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == buf_name then
        existing_buf = b
        break
      end
    end

    local buf
    if existing_buf then
      buf = existing_buf
      -- Switch to existing tab/window if possible
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
          vim.api.nvim_set_current_win(win)
          -- Refresh content
          vim.bo[buf].modifiable = true
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].modified = false
          notify(key .. " refreshed")
          return
        end
      end
      -- Buffer exists but no window showing it — open in new tab
      vim.cmd("tabnew")
      vim.api.nvim_set_current_buf(buf)
      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].modified = false
    else
      -- Create new buffer in a new tab
      vim.cmd("tabnew")
      buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_name(buf, buf_name)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end

    -- Buffer settings
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].buftype = "acwrite" -- allows :w to trigger BufWriteCmd
    vim.bo[buf].swapfile = false
    vim.bo[buf].modified = false

    -- BufWriteCmd: intercept :w and sync to Jira
    vim.api.nvim_create_autocmd("BufWriteCmd", {
      buffer = buf,
      callback = function()
        save_issue_buffer(buf, key)
      end,
    })

    -- Dim the comments section (read-only zone) with extmarks
    local ns = vim.api.nvim_create_namespace("jira_readonly")
    for idx, line in ipairs(lines) do
      if line:match("^<!%-%- COMMENTS %(read%-only%)") then
        -- Dim from this line to end of buffer
        for dim_idx = idx, #lines do
          pcall(vim.api.nvim_buf_set_extmark, buf, ns, dim_idx - 1, 0, {
            line_hl_group = "Comment",
          })
        end
        break
      end
    end

    -- Place cursor on line 1, ready to edit
    vim.api.nvim_win_set_cursor(0, { 1, 2 })
    notify(key .. " opened for editing (:w to save to Jira)")
  end)
end

-- ─── ISSUE DETAIL VIEW ────────────────────────────────────

--- Fetch full issue details and show in a rich markdown float
function pipeline.view_issue(issue_key)
  if not issue_key then
    -- If no key provided, check active ticket or open Telescope picker
    if state.active_ticket then
      issue_key = state.active_ticket.key
    else
      pick_ticket_then("View Issue - Select Ticket", function(issue)
        pipeline.view_issue(issue.key)
      end)
      return
    end
  end

  notify("Fetching " .. issue_key .. "...")

  local path = "/issue/" .. issue_key
    .. "?fields=summary,description,status,priority,issuetype,assignee,reporter,"
    .. "created,updated,customfield_10016,parent,subtasks,issuelinks,comment"

  jira_request("GET", path, nil, function(err, data)
    if err then
      notify("Failed to fetch issue: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if not data or not data.fields then
      notify("Invalid issue response", vim.log.levels.ERROR)
      return
    end

    local f = data.fields
    local lines = {}

    -- Header
    table.insert(lines, "# " .. data.key .. " - " .. (f.summary or ""))
    table.insert(lines, "")

    -- Metadata table
    table.insert(lines, "| Field | Value |")
    table.insert(lines, "|-------|-------|")
    table.insert(lines, string.format("| **Status** | %s |", safe_field(f, "status", "name") or "?"))
    table.insert(lines, string.format("| **Type** | %s |", safe_field(f, "issuetype", "name") or "?"))
    table.insert(lines, string.format("| **Priority** | %s |", safe_field(f, "priority", "name") or "?"))
    table.insert(lines, string.format("| **Story Points** | %s |", tostring(safe(f.customfield_10016) or "?")))
    table.insert(lines, string.format("| **Assignee** | %s |",
      safe_field(f, "assignee", "displayName") or "Unassigned"))
    table.insert(lines, string.format("| **Reporter** | %s |",
      safe_field(f, "reporter", "displayName") or "?"))
    if safe(f.parent) then
      table.insert(lines, string.format("| **Parent** | %s - %s |",
        f.parent.key or "?", safe_field(f, "parent", "fields", "summary") or "?"))
    end
    table.insert(lines, string.format("| **Created** | %s |", (safe(f.created) or "?"):sub(1, 10)))
    table.insert(lines, string.format("| **Updated** | %s |", (safe(f.updated) or "?"):sub(1, 10)))
    table.insert(lines, "")

    -- Description
    table.insert(lines, "## Description")
    table.insert(lines, "")
    local desc = extract_description(safe(f.description))
    for _, line in ipairs(vim.split(desc, "\n")) do
      table.insert(lines, line)
    end
    table.insert(lines, "")

    -- Subtasks
    if safe(f.subtasks) and #f.subtasks > 0 then
      table.insert(lines, "## Subtasks")
      table.insert(lines, "")
      for _, sub in ipairs(f.subtasks) do
        local sub_status = safe_field(sub, "fields", "status", "name") or "?"
        local check = (sub_status:lower() == "done") and "x" or " "
        table.insert(lines, string.format("- [%s] **%s** %s (%s)",
          check, sub.key or "?", safe_field(sub, "fields", "summary") or "?", sub_status))
      end
      table.insert(lines, "")
    end

    -- Linked issues
    if safe(f.issuelinks) and #f.issuelinks > 0 then
      table.insert(lines, "## Linked Issues")
      table.insert(lines, "")
      for _, link in ipairs(f.issuelinks) do
        local link_type = safe_field(link, "type", "outward") or "related to"
        local linked_issue = safe(link.outwardIssue) or safe(link.inwardIssue)
        if linked_issue then
          local linked_status = safe_field(linked_issue, "fields", "status", "name") or "?"
          table.insert(lines, string.format("- **%s** %s: %s (%s)",
            linked_issue.key or "?", link_type,
            safe_field(linked_issue, "fields", "summary") or "?",
            linked_status))
        end
      end
      table.insert(lines, "")
    end

    -- Comments
    table.insert(lines, "## Comments")
    table.insert(lines, "")
    local comments = (safe(f.comment) and safe(f.comment.comments)) or {}
    if #comments == 0 then
      table.insert(lines, "_No comments_")
    else
      for _, comment in ipairs(comments) do
        local author = safe_field(comment, "author", "displayName") or "Unknown"
        local timestamp = (safe(comment.updated) or safe(comment.created) or "?"):sub(1, 16):gsub("T", " ")
        table.insert(lines, string.format("### %s  _%s_", author, timestamp))
        table.insert(lines, "")
        local body = adf_to_text(comment.body)
        for _, line in ipairs(vim.split(body, "\n")) do
          table.insert(lines, line)
        end
        table.insert(lines, "")
        table.insert(lines, "---")
        table.insert(lines, "")
      end
    end

    -- Open in a float
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].buftype = "nofile"

    local width  = math.min(90, vim.o.columns - 8)
    local height = math.min(#lines + 2, vim.o.lines - 6)
    local row    = math.floor((vim.o.lines - height) / 2)
    local col    = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
      relative  = "editor",
      width     = width,
      height    = height,
      row       = row,
      col       = col,
      style     = "minimal",
      border    = "rounded",
      title     = " " .. data.key .. " ",
      title_pos = "center",
    })

    -- Keymaps in the float
    local float_opts = { buffer = buf, noremap = true, silent = true }
    vim.keymap.set("n", "q",     function() vim.api.nvim_win_close(win, true) end, float_opts)
    vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, float_opts)
    vim.keymap.set("n", "t", function()
      transition_picker(data.key)
    end, float_opts)
  end)
end

-- ─── TELESCOPE TICKET PICKER (MULTI-PROJECT) ──────────────

function pipeline.pick_ticket(opts)
  opts = opts or {}

  local ok_t = pcall(require, "telescope")
  if not ok_t then
    notify("telescope.nvim not found", vim.log.levels.ERROR)
    return
  end

  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local function show_picker(issues, title)
    if #issues == 0 then
      notify("No tickets found", vim.log.levels.WARN)
      return
    end

    notify(string.format("Found %d tickets", #issues))

    pickers.new({}, {
      prompt_title = title or "Jira Tickets (All Projects)",
      finder = finders.new_table({
        results = issues,
        entry_maker = function(issue)
          local f = issue.fields
          local status_name = safe_field(f, "status", "name") or "?"
          local itype       = safe_field(f, "issuetype", "name") or "?"
          local points      = safe(f.customfield_10016) or "-"
          local label = string.format(
            "[%s] [%s] [%s] [%ssp] %s",
            issue.key, status_name, itype, tostring(points), f.summary or ""
          )
          return { value = issue, display = label, ordinal = label }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = require("telescope.previewers").new_buffer_previewer({
        title = "Ticket Details",
        define_preview = function(self, entry)
          local issue = entry.value
          local f = issue.fields
          local desc = extract_description(safe(f.description))

          -- Build preview lines
          local preview_lines = {
            "KEY:      " .. issue.key,
            "SUMMARY:  " .. (f.summary or ""),
            "STATUS:   " .. (safe_field(f, "status", "name") or "?"),
            "TYPE:     " .. (safe_field(f, "issuetype", "name") or "?"),
            "PRIORITY: " .. (safe_field(f, "priority", "name") or "?"),
            "POINTS:   " .. tostring(safe(f.customfield_10016) or "?"),
            "",
            "--- DESCRIPTION ---",
            "",
          }
          for _, line in ipairs(vim.split(desc, "\n")) do
            table.insert(preview_lines, line)
          end

          -- Subtasks in preview
          if safe(f.subtasks) and #f.subtasks > 0 then
            table.insert(preview_lines, "")
            table.insert(preview_lines, "--- SUBTASKS ---")
            for _, sub in ipairs(f.subtasks) do
              local sub_status = safe_field(sub, "fields", "status", "name") or "?"
              table.insert(preview_lines, string.format(
                "  [%s] %s - %s (%s)",
                sub_status:lower() == "done" and "x" or " ",
                sub.key or "?",
                safe_field(sub, "fields", "summary") or "?",
                sub_status
              ))
            end
          end

          -- Comments count in preview
          local comments = (safe(f.comment) and safe(f.comment.comments)) or {}
          if #comments > 0 then
            table.insert(preview_lines, "")
            table.insert(preview_lines, string.format("--- COMMENTS (%d) ---", #comments))
            -- Show last 3 comments
            local start_idx = math.max(1, #comments - 2)
            for i = start_idx, #comments do
              local c = comments[i]
              local author = safe_field(c, "author", "displayName") or "?"
              local time = (safe(c.updated) or safe(c.created) or "?"):sub(1, 16):gsub("T", " ")
              table.insert(preview_lines, "")
              table.insert(preview_lines, string.format("  %s (%s):", author, time))
              local body = adf_to_text(safe(c.body))
              for _, line in ipairs(vim.split(body, "\n")) do
                if line ~= "" then
                  table.insert(preview_lines, "    " .. line)
                end
              end
            end
          end

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        -- <CR> = start full pipeline (branch + timer + transition)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          pipeline.start_session(entry.value)
        end)

        -- <C-a> = send to Avante only
        map("i", "<C-a>", function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          pipeline.send_to_avante(entry.value)
        end)

        -- <C-t> = transition picker (shows available transitions)
        map("i", "<C-t>", function()
          local entry = action_state.get_selected_entry()
          transition_picker(entry.value.key)
        end)
        map("n", "t", function()
          local entry = action_state.get_selected_entry()
          transition_picker(entry.value.key)
        end)

        -- <C-v> = view full issue detail
        map("i", "<C-v>", function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          pipeline.view_issue(entry.value.key)
        end)
        map("n", "v", function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          pipeline.view_issue(entry.value.key)
        end)

        return true
      end,
    }):find()
  end

  -- If a specific project was requested, fetch just that
  if opts.project_key then
    notify("Fetching tickets for " .. opts.project_key .. "...")
    fetch_tickets({ project_key = opts.project_key }, function(err, data)
      if err then
        notify("Fetch failed: " .. tostring(err), vim.log.levels.ERROR)
        return
      end
      show_picker(data and data.issues or {}, "Jira: " .. opts.project_key)
    end)
  else
    -- Offer: all projects or pick one
    vim.ui.select(
      { "All Projects", "Pick a Project" },
      { prompt = "Jira Ticket Scope:" },
      function(choice)
        if not choice then return end

        if choice == "All Projects" then
          notify("Fetching tickets across all projects...")
          fetch_tickets({}, function(err, data)
            if err then
              notify("Fetch failed: " .. tostring(err), vim.log.levels.ERROR)
              return
            end
            show_picker(data and data.issues or {}, "Jira: All Projects")
          end)
        else
          -- Pick a project first
          pick_project("Pick Project to Browse", function(project)
            notify("Fetching tickets for " .. project.key .. "...")
            fetch_tickets({ project_key = project.key }, function(err, data)
              if err then
                notify("Fetch failed: " .. tostring(err), vim.log.levels.ERROR)
                return
              end
              show_picker(data and data.issues or {}, "Jira: " .. project.key)
            end)
          end)
        end
      end
    )
  end
end

-- ─── CREATE ISSUE (MULTI-PROJECT) ─────────────────────────

function pipeline.create_issue()
  local ok_t = pcall(require, "telescope")
  if not ok_t then
    notify("telescope.nvim not found", vim.log.levels.ERROR)
    return
  end

  -- Step 1: Pick project
  pick_project("Create Issue - Select Project", function(project)
    -- Step 2: Pick issue type
    local issue_types = { "Task", "Story", "Bug", "Sub-task" }
    vim.ui.select(issue_types, { prompt = "Issue Type:" }, function(issue_type)
      if not issue_type then return end

      -- Step 3: Enter title
      vim.ui.input({ prompt = "Summary (" .. project.key .. " " .. issue_type .. "): " }, function(summary)
        if not summary or summary == "" then
          notify("Cancelled - no summary provided", vim.log.levels.WARN)
          return
        end

        -- Step 4: Enter description
        vim.ui.input({ prompt = "Description (optional): " }, function(description)
          description = description or ""

          local body = {
            fields = {
              project   = { key = project.key },
              summary   = summary,
              issuetype = { name = issue_type },
            },
          }

          -- Add description in ADF format if provided
          if description ~= "" then
            body.fields.description = {
              type    = "doc",
              version = 1,
              content = { {
                type    = "paragraph",
                content = { { type = "text", text = description } },
              } },
            }
          end

          notify("Creating " .. issue_type .. " in " .. project.key .. "...")

          jira_request("POST", "/issue", body, function(err, data)
            if err then
              notify("Create failed: " .. tostring(err), vim.log.levels.ERROR)
              return
            end
            if data and data.key then
              notify(string.format("Created %s: %s", data.key, summary))
              -- Ask if they want to start working on it
              vim.ui.select(
                { "Yes - start session", "No - just create" },
                { prompt = "Start working on " .. data.key .. "?" },
                function(choice)
                  if choice and choice:sub(1, 3) == "Yes" then
                    -- Fetch the full issue to start session
                    jira_request("GET", "/issue/" .. data.key
                      .. "?fields=summary,description,status,priority,issuetype,customfield_10016",
                      nil,
                      function(ferr, fdata)
                        if ferr or not fdata then
                          notify("Could not fetch created issue", vim.log.levels.WARN)
                          return
                        end
                        pipeline.start_session(fdata)
                      end
                    )
                  end
                end
              )
            else
              notify("Created issue but got unexpected response", vim.log.levels.WARN)
            end
          end)
        end)
      end)
    end)
  end)
end

-- ─── DEBUG / TEST CONNECTION ───────────────────────────────

function pipeline.test_connection()
  notify("Testing Jira API connection...")

  jira_request("GET", "/myself", nil, function(err, data)
    if err then
      notify("Auth FAILED: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if data and data.displayName then
      notify("Auth OK: " .. data.displayName)
    else
      notify("Auth response unexpected: " .. vim.inspect(data):sub(1, 200), vim.log.levels.WARN)
      return
    end

    -- List all projects
    jira_request("GET", "/project?recent=20", nil, function(err2, projects)
      if err2 then
        notify("Project list failed: " .. tostring(err2), vim.log.levels.ERROR)
        return
      end
      if type(projects) == "table" then
        -- Cache them
        cached_projects = {}
        local project_list = {}
        for _, p in ipairs(projects) do
          table.insert(project_list, string.format("  %s - %s", p.key, p.name))
          table.insert(cached_projects, { key = p.key, name = p.name })
        end
        local msg = string.format(
          "Your projects (%d):\n%s",
          #project_list,
          table.concat(project_list, "\n")
        )
        notify(msg)
      end
    end)
  end)
end

-- ─── SESSION START ─────────────────────────────────────────

function pipeline.start_session(issue)
  local key     = issue.key
  local summary = safe_field(issue, "fields", "summary") or key
  local desc    = extract_description(safe_field(issue, "fields", "description"))

  state.active_ticket = { key = key, summary = summary, description = desc }
  state.timer_start   = os.time()

  -- Auto-create git branch
  local branch = string.lower(key .. "-" .. summary:gsub("[^%w]+", "-"):sub(1, 40))
  vim.fn.jobstart({ "git", "checkout", "-b", branch }, {
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          notify("Branch: " .. branch)
          add_comment(key, "Branch created: `" .. branch .. "` via Neovim")
        else
          vim.fn.jobstart({ "git", "checkout", branch }, { detach = true })
          notify("Switched to existing branch: " .. branch)
        end
      end)
    end,
  })

  -- Transition to In Progress
  transition_ticket(key, "In Progress", function()
    notify(key .. " -> In Progress")
  end)

  -- Show floating summary
  pipeline.show_ticket_float()

  -- Start statusline refresh timer
  if state.timer_handle then state.timer_handle:stop() end
  state.timer_handle = vim.uv.new_timer()
  state.timer_handle:start(0, 60000, vim.schedule_wrap(function()
    vim.cmd("redrawstatus")
  end))

  notify(string.format("Session started: %s - %s", key, summary))
end

-- ─── AVANTE INTEGRATION ────────────────────────────────────

function pipeline.send_to_avante(issue)
  local key     = issue.key
  local summary = safe_field(issue, "fields", "summary") or key
  local desc    = extract_description(safe_field(issue, "fields", "description"))

  local prompt = string.format([[
You are a Flutter developer. Generate production-ready Flutter code for this Jira ticket.

TICKET: %s
SUMMARY: %s

DESCRIPTION & ACCEPTANCE CRITERIA:
%s

REQUIREMENTS:
1. Create a clean Flutter widget/feature implementing the acceptance criteria
2. Follow BLoC or Riverpod pattern (use whatever fits the context)
3. Include a corresponding _test.dart file with widget tests for each acceptance criterion
4. Add meaningful comments referencing the ticket key %s
5. Use proper error handling and loading states
6. Output: widget file first, then test file, separated by --- TEST FILE ---
]], key, summary, desc, key)

  local ok, avante = pcall(require, "avante")
  if ok and avante.ask then
    avante.ask({ question = prompt })
    notify("Sent " .. key .. " to Avante")
  else
    -- Fallback: open buffer with prompt
    vim.cmd("vnew")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(prompt, "\n"))
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].buftype = "nofile"
    notify("Avante not available - prompt ready in buffer", vim.log.levels.WARN)
  end
end

-- ─── TICKET FLOAT (session summary) ───────────────────────

function pipeline.show_ticket_float()
  if not state.active_ticket then
    notify("No active ticket session", vim.log.levels.WARN)
    return
  end

  local t = state.active_ticket
  local lines = {}
  table.insert(lines, "  " .. t.key .. " - " .. t.summary)
  table.insert(lines, string.rep("-", 60))
  table.insert(lines, "  Elapsed: " .. format_elapsed())
  table.insert(lines, "")
  for _, line in ipairs(vim.split(t.description, "\n")) do
    table.insert(lines, " " .. line)
    if #lines > 30 then
      table.insert(lines, " ... (truncated)")
      break
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local width  = math.min(70, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 6)

  vim.api.nvim_open_win(buf, false, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = 2,
    col       = vim.o.columns - width - 2,
    style     = "minimal",
    border    = "rounded",
    title     = " Jira Session ",
    title_pos = "center",
  })

  -- Auto-close after 8 seconds
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end, 8000)
end

-- ─── END SESSION / WORKLOG ─────────────────────────────────

function pipeline.end_session()
  if not state.active_ticket then
    notify("No active session to end", vim.log.levels.WARN)
    return
  end

  local key     = state.active_ticket.key
  local seconds = elapsed_seconds()
  local elapsed = format_elapsed()

  vim.ui.select(
    { "Yes - log " .. elapsed .. " to " .. key, "No - discard time" },
    { prompt = "Log worklog to Jira?" },
    function(choice)
      if choice and choice:sub(1, 3) == "Yes" then
        post_worklog(key, seconds, function(err)
          if err then
            notify("Worklog failed: " .. tostring(err), vim.log.levels.ERROR)
          else
            notify("Logged " .. elapsed .. " to " .. key)
          end
        end)
      end
      state.active_ticket = nil
      state.timer_start   = nil
      if state.timer_handle then
        state.timer_handle:stop()
        state.timer_handle = nil
      end
    end
  )
end

-- ─── FLUTTER-AWARE AUTOCMDS ───────────────────────────────

local function setup_flutter_autocmds()
  local group = vim.api.nvim_create_augroup("JiraFlutterWatcher", { clear = true })

  -- Creating a _test.dart -> comment on ticket
  vim.api.nvim_create_autocmd("BufNewFile", {
    group   = group,
    pattern = "*_test.dart",
    callback = function(args)
      if state.active_ticket then
        add_comment(
          state.active_ticket.key,
          "Test file created: `" .. vim.fn.fnamemodify(args.file, ":t") .. "`"
        )
      end
    end,
  })

  -- On LazyGit terminal close -> suggest In Review
  vim.api.nvim_create_autocmd("TermClose", {
    group   = group,
    pattern = "*lazygit*",
    callback = function()
      if not state.active_ticket then return end
      local key = state.active_ticket.key
      vim.defer_fn(function()
        vim.ui.select(
          { "Yes - move to In Review", "No - keep as is" },
          { prompt = "[Jira] Move " .. key .. " to In Review?" },
          function(choice)
            if choice and choice:sub(1, 3) == "Yes" then
              transition_ticket(key, "In Review", function()
                notify(key .. " -> In Review")
              end)
            end
          end
        )
      end, 1000)
    end,
  })
end

-- ─── STATUSLINE COMPONENT ──────────────────────────────────

function pipeline.statusline()
  if not state.active_ticket then return "" end
  return string.format("JIRA %s [%s]", state.active_ticket.key, format_elapsed())
end

-- ─── COMMANDS ──────────────────────────────────────────────

local function setup_commands()
  vim.api.nvim_create_user_command("JiraPick", function()
    pipeline.pick_ticket()
  end, { desc = "Pick a Jira ticket (Telescope, multi-project)" })

  vim.api.nvim_create_user_command("JiraCreate", function()
    pipeline.create_issue()
  end, { desc = "Create a Jira issue (project picker)" })

  vim.api.nvim_create_user_command("JiraView", function(args)
    pipeline.view_issue(args.args ~= "" and args.args or nil)
  end, { nargs = "?", desc = "View full issue detail (float)" })

  vim.api.nvim_create_user_command("JiraEdit", function(args)
    pipeline.edit_issue(args.args ~= "" and args.args or nil)
  end, { nargs = "?", desc = "Edit issue in buffer (:w syncs to Jira)" })

  vim.api.nvim_create_user_command("JiraEnd", pipeline.end_session, {
    desc = "End session + log worklog",
  })

  vim.api.nvim_create_user_command("JiraFloat", pipeline.show_ticket_float, {
    desc = "Show active ticket float",
  })

  vim.api.nvim_create_user_command("JiraAvante", function()
    if state.active_ticket then
      pipeline.send_to_avante({
        key = state.active_ticket.key,
        fields = {
          summary     = state.active_ticket.summary,
          description = state.active_ticket.description,
        },
      })
    else
      -- No active ticket: open Telescope picker first
      pick_ticket_then("Send to Avante - Select Ticket", function(issue)
        pipeline.send_to_avante(issue)
      end)
    end
  end, { desc = "Send ticket to Avante for Flutter codegen" })

  vim.api.nvim_create_user_command("JiraTransition", function(args)
    if args.args and args.args ~= "" then
      -- Direct transition by name (for automation)
      if state.active_ticket then
        transition_ticket(state.active_ticket.key, args.args, function()
          notify(state.active_ticket.key .. " -> " .. args.args)
        end)
      else
        notify("No active ticket", vim.log.levels.WARN)
      end
    else
      -- Interactive picker: active ticket or Telescope first
      if state.active_ticket then
        transition_picker(state.active_ticket.key)
      else
        pick_ticket_then("Transition - Select Ticket", function(issue)
          transition_picker(issue.key)
        end)
      end
    end
  end, { nargs = "?", desc = "Transition ticket status (picker or by name)" })

  vim.api.nvim_create_user_command("JiraTest", pipeline.test_connection, {
    desc = "Test Jira API connection and list projects",
  })
end

-- ─── PIPELINE SETUP ────────────────────────────────────────

function pipeline.setup()
  setup_commands()
  setup_flutter_autocmds()
  notify("Pipeline ready (multi-project) - <leader>jp to pick, <leader>jc to create")
end

-- ─── LAZY.NVIM PLUGIN SPEC ────────────────────────────────

return {
  "kid-icarus/jira.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "folke/snacks.nvim",
  },
  config = function()
    -- Ensure pipeline env vars are set (fallback if shell didn't export them)
    vim.env.JIRA_BASE_URL = vim.env.JIRA_BASE_URL or "https://sayaratech.atlassian.net"
    vim.env.JIRA_EMAIL    = vim.env.JIRA_EMAIL    or "migdad@sayaratech.com"

    -- 1) Setup base jira.nvim plugin
    require("jira").setup({
      jira_api = {
        domain   = vim.env.JIRA_DOMAIN   or "sayaratech.atlassian.net",
        username = vim.env.JIRA_USER     or "migdad@sayaratech.com",
        token    = vim.env.JIRA_API_TOKEN,
      },
      use_git_branch_issue_id = true,
      git_trunk_branch = "main",
      git_branch_prefix = "feature/",
    })

    -- 2) Patch upstream bug: commands.lua:89 uses response.code but
    --    plenary.curl returns response.status. Monkey-patch view_issue.
    local ok_cmds, jira_cmds = pcall(require, "jira.commands")
    if ok_cmds and jira_cmds.view_issue then
      local ok_api, api_client = pcall(require, "jira.api_client")
      local ok_utils, utils    = pcall(require, "jira.utils")
      if ok_api and ok_utils then
        jira_cmds.view_issue = function(issue_id)
          issue_id = issue_id or utils.get_issue_id()
          if not issue_id then
            notify("Missing issue id - provide one or use a branch with an issue id", vim.log.levels.WARN)
            return
          end

          local response = api_client.get_issue(issue_id)
          if not response then
            notify("No response from Jira API", vim.log.levels.ERROR)
            return
          end

          if response.status and response.status < 400 then
            vim.schedule(function()
              local parse_ok, data = pcall(vim.fn.json_decode, response.body)
              if not parse_ok then
                notify("Failed to parse issue response", vim.log.levels.ERROR)
                return
              end
              -- Use our rich view instead of the basic upstream one
              pipeline.view_issue(data.key)
            end)
          else
            notify(
              string.format("Issue fetch failed (HTTP %s): %s",
                tostring(response.status or "?"),
                (response.body or ""):sub(1, 200)
              ),
              vim.log.levels.ERROR
            )
          end
        end
      end
    end

    -- 3) Setup the pipeline (commands, autocmds)
    pipeline.setup()

    -- 4) Keymaps
    local keymap = vim.keymap

    -- Pipeline commands (multi-project)
    keymap.set("n", "<leader>jp", "<cmd>JiraPick<cr>",       { desc = "Jira: Pick Ticket (Multi-Project)" })
    keymap.set("n", "<leader>jc", "<cmd>JiraCreate<cr>",     { desc = "Jira: Create Issue (Project Picker)" })
    keymap.set("n", "<leader>ji", "<cmd>JiraView<cr>",       { desc = "Jira: View Issue Detail" })
    keymap.set("n", "<leader>jw", "<cmd>JiraEdit<cr>",       { desc = "Jira: Edit Issue (:w syncs)" })
    keymap.set("n", "<leader>ja", "<cmd>JiraAvante<cr>",     { desc = "Jira: Send to Avante" })
    keymap.set("n", "<leader>jf", "<cmd>JiraFloat<cr>",      { desc = "Jira: Show Session Float" })
    keymap.set("n", "<leader>jx", "<cmd>JiraEnd<cr>",        { desc = "Jira: End Session + Log Time" })
    keymap.set("n", "<leader>jt", "<cmd>JiraTransition<cr>", { desc = "Jira: Transition Status (Picker)" })
    keymap.set("n", "<leader>jd", "<cmd>JiraTest<cr>",       { desc = "Jira: Test Connection + List Projects" })

    -- Base jira.nvim commands (upstream, still uses patched view_issue)
    keymap.set("n", "<leader>jv", "<cmd>Jira issue view<cr>",  { desc = "Jira: View Issue (upstream)" })

    -- NOTE: <leader>je and <leader>js REMOVED — upstream jira.pickers.telescope
    -- and jira.pickers.snacks are broken (nil crashes). All transitions now
    -- go through <leader>jt which uses our own Telescope picker.
  end,

  -- Expose pipeline functions for lualine / external use
  statusline = pipeline.statusline,
}
