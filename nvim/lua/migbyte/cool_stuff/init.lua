-- this is the module entrypoint; must live at
-- ~/.config/nvim/lua/migbyte/cool_stuff/init.lua

local todo = require("migbyte.cool_stuff.todo_float")
local M    = {}

function M.setup(opts)
  todo.setup(opts)
end

return M
