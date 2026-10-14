-- tmux copy mode in Neovim (prefix + v, opened by vimcopy.sh over the pane).
--   relative line numbers   → 5j / 12k land where the gutter says
--   s / S                   → flash.nvim jump / jump to a line (your nvim flash opts)
--   y (normal + visual)     → copy to clipboard + tmux buffer, cursor stays put
--   <CR> in visual          → copy and close
--   q / <Esc> / <C-c>       → close (<Esc> first clears a search highlight)

vim.loader.enable()
vim.g.mapleader = " "
vim.cmd("syntax off | filetype off")

local api, env = vim.api, vim.env

local o = vim.o
o.number = false
o.relativenumber = true
o.numberwidth = 3
o.cursorline = true
o.cursorlineopt = "number"
o.wrap = false
o.sidescroll = 1
o.scrolloff = 0
o.sidescrolloff = 0
o.laststatus = 0
o.cmdheight = 0
o.ruler = false
o.showmode = false
o.showcmd = false
o.signcolumn = "no"
o.fillchars = "eob: "
o.ignorecase = true
o.smartcase = true
o.mouse = "a"
o.ttimeoutlen = 10 -- Esc closes without the 50ms wait for an escape sequence
o.report = 9999
o.messagesopt = "wait:0,history:200" -- cmdheight=0: never block on a "Press ENTER" prompt
o.shortmess = o.shortmess .. "IFsWcS"
o.termguicolors = true
o.background = "dark" -- set explicitly so terminal bg detection never resets the colors below
o.clipboard = "unnamedplus"

-- Clipboard: synchronous, so "copy and close" can't lose the copy. Also fills the
-- tmux paste buffer (prefix + ]). Linewise yanks get no trailing newline, so a
-- copied command doesn't run itself when pasted into a shell.
local function copy(lines)
  local text = table.concat(lines, "\n")
  vim.system({ "tmux", "load-buffer", "-" }, { stdin = text }):wait()
  if vim.fn.executable("pbcopy") == 1 then
    vim.system({ "pbcopy" }, { stdin = text }):wait()
  else
    vim.system({ "tmux", "load-buffer", "-w", "-" }, { stdin = text }):wait()
  end
end
local function paste()
  return { vim.fn.systemlist(vim.fn.executable("pbpaste") == 1 and "pbpaste" or "tmux save-buffer -"), "v" }
end
vim.g.clipboard = {
  name = "tmux-vimcopy",
  copy = { ["+"] = copy, ["*"] = copy },
  paste = { ["+"] = paste, ["*"] = paste },
}

---------------------------------------------------------------------------
-- Colors: the pane's own ANSI colors, with 0–15 taken from kitty's palette.
---------------------------------------------------------------------------
local palette = {
  [0] = "#000000", "#cc0403", "#19cb00", "#cecb00", "#0d73cc", "#cb1ed1", "#0dcdcd", "#dddddd",
  "#767676", "#f2201f", "#23fd00", "#ffff00", "#1a8fff", "#fd28ff", "#14ffff", "#ffffff",
}
local default_fg, default_bg = "#dddddd", "#1a1a1a"

local function read_kitty(path, depth)
  local f = depth < 4 and io.open(path)
  if not f then return end
  for line in f:lines() do
    local key, value = line:match("^%s*(%S+)%s+(%S+)")
    if key == "include" then
      read_kitty(value:sub(1, 1) == "/" and value or vim.fs.dirname(path) .. "/" .. value, depth + 1)
    elseif value and value:match("^#%x%x%x%x%x%x$") then
      local n = tonumber(key:match("^color(%d+)$"))
      if n and n < 16 then palette[n] = value end
      if key == "foreground" then default_fg = value end
      if key == "background" then default_bg = value end
    end
  end
  f:close()
end
read_kitty((env.KITTY_CONFIG_DIRECTORY or vim.fn.expand("~/.config/kitty")) .. "/kitty.conf", 0)

local function color256(n)
  n = tonumber(n)
  if not n then return nil end
  if n < 16 then return palette[n] end
  if n >= 232 then
    local v = 8 + (n - 232) * 10
    return string.format("#%02x%02x%02x", v, v, v)
  end
  n = n - 16
  local function level(i) return i == 0 and 0 or 55 + i * 40 end
  return string.format("#%02x%02x%02x", level(math.floor(n / 36)), level(math.floor(n / 6) % 6), level(n % 6))
end

local function rgb(r, g, b)
  return string.format("#%02x%02x%02x", tonumber(r) or 0, tonumber(g) or 0, tonumber(b) or 0)
end

local function blend(a, b, t)
  local function ch(hex, i) return tonumber(hex:sub(i, i + 1), 16) end
  local function mix(i) return math.floor(ch(a, i) * (1 - t) + ch(b, i) * t + 0.5) end
  return string.format("#%02x%02x%02x", mix(2), mix(4), mix(6))
end

-- SGR state machine. Attributes carry across lines in tmux's capture output.
local function set_color(st, which, value)
  if which == 38 then st.fg = value elseif which == 48 then st.bg = value else st.sp = value end
end

local function apply_sgr(st, params)
  local fields = vim.split(params == "" and "0" or params, ";", { plain = true })
  local i = 1
  while i <= #fields do
    local f = fields[i]
    if f:find(":", 1, true) then
      local sub = vim.split(f, ":", { plain = true })
      local n = tonumber(sub[1])
      if n == 4 then
        local style = tonumber(sub[2]) or 1
        st.ul = style ~= 0 and style or nil
      elseif n == 38 or n == 48 or n == 58 then
        if sub[2] == "5" then
          set_color(st, n, color256(sub[3]))
        elseif sub[2] == "2" then
          local k = #sub >= 6 and 4 or 3 -- 38:2:<colorspace>:r:g:b or 38:2:r:g:b
          set_color(st, n, rgb(sub[k], sub[k + 1], sub[k + 2]))
        end
      end
    else
      local n = tonumber(f) or 0
      if n == 38 or n == 48 or n == 58 then
        local mode = fields[i + 1]
        if mode == "5" then
          set_color(st, n, color256(fields[i + 2]))
          i = i + 2
        elseif mode == "2" then
          set_color(st, n, rgb(fields[i + 2], fields[i + 3], fields[i + 4]))
          i = i + 4
        end
      elseif n == 0 then
        for k in pairs(st) do st[k] = nil end
      elseif n == 1 then st.bold = true
      elseif n == 2 then st.dim = true
      elseif n == 3 then st.italic = true
      elseif n == 4 then st.ul = 1
      elseif n == 7 then st.reverse = true
      elseif n == 9 then st.strike = true
      elseif n == 21 then st.ul = 2
      elseif n == 22 then st.bold, st.dim = nil, nil
      elseif n == 23 then st.italic = nil
      elseif n == 24 then st.ul = nil
      elseif n == 27 then st.reverse = nil
      elseif n == 29 then st.strike = nil
      elseif n >= 30 and n <= 37 then st.fg = palette[n - 30]
      elseif n == 39 then st.fg = nil
      elseif n >= 40 and n <= 47 then st.bg = palette[n - 40]
      elseif n == 49 then st.bg = nil
      elseif n == 59 then st.sp = nil
      elseif n >= 90 and n <= 97 then st.fg = palette[n - 82]
      elseif n >= 100 and n <= 107 then st.bg = palette[n - 92]
      end
    end
    i = i + 1
  end
end

local groups, ngroups = {}, 0
-- Highlight group for a state; `solid` marks styles that show on blank cells.
local function group_for(st)
  if not next(st) then return nil end
  local key = table.concat({
    st.fg or "", st.bg or "", st.sp or "", st.ul or "",
    st.bold and "b" or "", st.dim and "d" or "", st.italic and "i" or "",
    st.reverse and "r" or "", st.strike and "s" or "",
  }, ",")
  local g = groups[key]
  if not g then
    ngroups = ngroups + 1
    g = { name = "VimcopyAnsi" .. ngroups, solid = (st.bg or st.reverse or st.ul or st.strike) and true or false }
    api.nvim_set_hl(0, g.name, {
      fg = st.dim and blend(st.fg or default_fg, default_bg, 0.45) or st.fg,
      bg = st.bg,
      sp = st.sp,
      bold = st.bold,
      italic = st.italic,
      reverse = st.reverse,
      strikethrough = st.strike,
      underline = st.ul == 1,
      underdouble = st.ul == 2,
      undercurl = st.ul == 3,
      underdotted = st.ul == 4,
      underdashed = st.ul == 5,
    })
    groups[key] = g
  end
  return g
end

-- One captured line → plain text + highlight spans { start_byte, end_byte, group }.
local function parse_line(raw, st)
  local parts, spans, n = {}, {}, 0
  local g, gstart = group_for(st), 0
  local keep = 0 -- trailing blanks that are visibly styled (a bg bar, say) are kept
  local function flush()
    if g and n > gstart then
      spans[#spans + 1] = { gstart, n, g.name }
      if g.solid then keep = n end
    end
  end
  local pos, len = 1, #raw
  while pos <= len do
    local esc = raw:find("\27", pos, true)
    if not esc then
      parts[#parts + 1] = raw:sub(pos)
      n = n + len - pos + 1
      break
    end
    if esc > pos then
      parts[#parts + 1] = raw:sub(pos, esc - 1)
      n = n + esc - pos
    end
    local kind = raw:sub(esc + 1, esc + 1)
    if kind == "[" then
      local params, final, after = raw:match("^([%d;:?<=>]*)[ -/]*([@-~])()", esc + 2)
      if after then
        if final == "m" then
          flush()
          apply_sgr(st, params)
          g, gstart = group_for(st), n
        end
        pos = after
      else
        pos = esc + 1
      end
    elseif kind == "]" then -- OSC (hyperlinks): drop, up to BEL or ST
      local bel = raw:find("\7", esc + 2, true)
      local st_ = raw:find("\27\\", esc + 2, true)
      local stop = math.min(bel and bel + 1 or len + 1, st_ and st_ + 2 or len + 1)
      pos = stop
    else
      pos = esc + 2
    end
  end
  flush()
  local text = table.concat(parts)
  local width = text:find("[\128-\255]") and vim.fn.strdisplaywidth(text) or #text
  local e = #text
  while e > keep and text:byte(e) == 32 do e = e - 1 end
  if e < #text then
    text = text:sub(1, e)
    for i = #spans, 1, -1 do
      local sp = spans[i]
      if sp[1] >= e then table.remove(spans, i) elseif sp[2] > e then sp[2] = e end
    end
  end
  return text, spans, width
end

---------------------------------------------------------------------------
-- Load the snapshot.
---------------------------------------------------------------------------
local pane_width = math.max(tonumber(env.VIMCOPY_WIDTH) or 80, 1)
local lines, spans, rows = {}, {}, {}
do
  local f = env.VIMCOPY_FILE and io.open(env.VIMCOPY_FILE, "rb")
  local data = f and f:read("*a") or ""
  if f then
    f:close()
    local dir = vim.fs.dirname(env.VIMCOPY_FILE)
    if vim.fs.basename(dir):match("^tmux%-vimcopy%.") then vim.fn.delete(dir, "rf") end
  end
  if data:sub(-1) == "\n" then data = data:sub(1, -2) end
  local st = {}
  for raw in (data .. "\n"):gmatch("(.-)\n") do
    local text, sp, width = parse_line(raw, st)
    local i = #lines + 1
    lines[i], spans[i] = text, sp[1] and sp or nil
    rows[i] = math.max(1, math.ceil(width / pane_width)) -- screen rows it took in the pane
  end
end

-- Map the pane's cursor (a screen row) onto the joined lines, and keep it on the
-- same screen row: with 'nowrap' every line is one row, so the top line follows.
local function locate(row)
  local start = 0
  for i = 1, #lines do
    if row < start + rows[i] then return i, row - start end
    start = start + rows[i]
  end
  return #lines, 0
end
local top_row = tonumber(env.VIMCOPY_TOP) or 0
local cur_row, cur_col = (env.VIMCOPY_CURSOR or ""):match("^(%d+),(%d+)$")
cur_row = tonumber(cur_row) or top_row
local cur_line, wrapped = locate(cur_row)
local cur_vcol = wrapped * pane_width + (tonumber(cur_col) or 0)
local top_line = math.max(1, cur_line - (cur_row - top_row))

-- Blank screen rows below the prompt are noise.
local last = #lines
while last > math.max(cur_line, 1) and lines[last] == "" and not spans[last] do last = last - 1 end
for i = #lines, last + 1, -1 do lines[i] = nil end

local buf = api.nvim_get_current_buf()
api.nvim_buf_set_lines(buf, 0, -1, false, lines)
vim.bo[buf].buftype = "nofile"
vim.bo[buf].bufhidden = "wipe"
vim.bo[buf].swapfile = false
vim.bo[buf].modified = false
vim.bo[buf].modifiable = false -- a snapshot, like tmux copy mode: a stray i/o/p can't edit it
api.nvim_buf_set_name(buf, "tmux scrollback")

local ns = api.nvim_create_namespace("vimcopy")
api.nvim_set_decoration_provider(ns, {
  on_line = function(_, _, b, row)
    local sp = b == buf and spans[row + 1]
    if not sp then return end
    for _, s in ipairs(sp) do
      api.nvim_buf_set_extmark(b, ns, row, s[1], { end_col = s[2], hl_group = s[3], ephemeral = true, priority = 50, strict = false })
    end
  end,
})

---------------------------------------------------------------------------
-- UI colors: transparent like the pane (kitty's opacity/background image show).
---------------------------------------------------------------------------
local function hl(name, val) api.nvim_set_hl(0, name, val) end
hl("Normal", {})
hl("NormalNC", {})
hl("NormalFloat", {})
hl("MsgArea", {})
hl("EndOfBuffer", {})
hl("LineNr", { fg = "#5c5f77" })
hl("CursorLineNr", { fg = "#cba6f7", bold = true })
hl("CursorLine", {})
hl("Visual", { bg = "#45475a" })
hl("Search", { fg = "#1a1a1a", bg = "#f9e2af" })
hl("CurSearch", { fg = "#1a1a1a", bg = "#fab387", bold = true })
hl("IncSearch", { link = "CurSearch" })
hl("VimcopyYank", { fg = "#1a1a1a", bg = "#a6e3a1" })

---------------------------------------------------------------------------
-- Keys.
---------------------------------------------------------------------------
local map = vim.keymap.set
local function quit() vim.cmd("qa!") end
map({ "n", "x" }, "q", quit, { desc = "Close" })
map({ "n", "x" }, "<C-c>", quit, { desc = "Close" })
map("n", "<Esc>", function()
  if vim.v.hlsearch == 1 and vim.fn.getreg("/") ~= "" then vim.cmd.nohlsearch() else quit() end
end, { desc = "Clear search / close" })
map("x", "<CR>", "y<Cmd>qa!<CR>", { desc = "Copy and close" })

-- y never moves the cursor: remember where it was, put it back after the yank.
local keep_cursor
map({ "n", "x" }, "y", function()
  keep_cursor = api.nvim_win_get_cursor(0)
  return "y"
end, { expr = true, desc = "Yank (cursor stays)" })
map("n", "Y", function()
  keep_cursor = api.nvim_win_get_cursor(0)
  return "y$"
end, { expr = true, desc = "Yank to end of line" })
api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ higroup = "VimcopyYank", timeout = 150 })
    if keep_cursor and vim.v.event.operator == "y" then
      pcall(api.nvim_win_set_cursor, 0, keep_cursor)
    end
    keep_cursor = nil
  end,
})

-- flash.nvim from your Neovim install, with the opts from your Neovim config.
local flash_dir = vim.fn.stdpath("data") .. "/lazy/flash.nvim"
if vim.uv.fs_stat(flash_dir) then
  vim.opt.rtp:prepend(flash_dir)
  local ok, spec = pcall(dofile, vim.fn.expand("~/.config/nvim/lua/migbyte/plugins/flash.lua"))
  local opts = ok and type(spec) == "table" and spec.opts or {}
  if type(opts) == "function" then opts = opts(spec, {}) or {} end
  local flash = require("flash")
  flash.setup(opts)
  map({ "n", "x", "o" }, "s", function() flash.jump() end, { desc = "Flash" })
  map({ "n", "x", "o" }, "S", function()
    flash.jump({ search = { mode = "search", max_length = 0 }, label = { after = { 0, 0 } }, pattern = "^" })
  end, { desc = "Flash to a line" })
  map("o", "r", function() flash.remote() end, { desc = "Remote flash" })
  map("o", "<leader>jr", function() flash.remote() end, { desc = "Remote flash" })
end

---------------------------------------------------------------------------
-- Open where the pane was looking, once the UI has its real size.
---------------------------------------------------------------------------
api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    local col = vim.fn.virtcol2col(0, cur_line, cur_vcol + 1)
    vim.fn.winrestview({ topline = top_line, lnum = cur_line, col = math.max(col - 1, 0), curswant = cur_vcol })
  end,
})
