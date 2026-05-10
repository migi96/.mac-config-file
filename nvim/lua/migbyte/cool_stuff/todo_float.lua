-- your real implementation; this file *must* live at
-- ~/.config/nvim/lua/migbyte/cool_stuff/todo_float.lua

local M = {}

function M.setup(opts)
  -- for now just print so we know it loaded:
  print("✔ todo_float.setup called with", vim.inspect(opts))
  -- … your actual logic here …
end

return M
