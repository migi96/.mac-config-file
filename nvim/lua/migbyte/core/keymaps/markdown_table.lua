-- keymaps/markdown_table.lua
local map = vim.keymap.set

local function make_md_table()
  local s = vim.fn.line("'<") - 1
  local e = vim.fn.line("'>")
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, s, e, false)

  -- split & measure
  local rows, cols, widths = {}, 0, {}
  for _, l in ipairs(lines) do
    local r = {}, 0
    for word in l:gmatch("%S+") do r[#r + 1] = word end
    rows[#rows + 1] = r; cols = math.max(cols, #r)
  end
  for i = 1, cols do widths[i] = 0 end
  for _, r in ipairs(rows) do
    for i = 1, cols do
      widths[i] = math.max(widths[i], #(r[i] or ""))
    end
  end

  -- rebuild
  local out = {}
  for ri, r in ipairs(rows) do
    local parts = {}
    for i = 1, cols do
      local cell = r[i] or ""
      parts[#parts + 1] = " " .. cell .. string.rep(" ", widths[i] - #cell) .. " "
    end
    out[#out + 1] = "|" .. table.concat(parts, "|") .. "|"
    if ri == 1 then
      local d = {}
      for _, w in ipairs(widths) do d[#d + 1] = " " .. string.rep("-", w) .. " " end
      out[#out + 1] = "|" .. table.concat(d, "|") .. "|"
    end
  end
  vim.api.nvim_buf_set_lines(buf, s, e, false, out)
end

map("v", "<leader>mt", function()
  vim.cmd("normal! gv") -- ensure visual range is set
  make_md_table()
end, { desc = "Visual → make MD table" })
