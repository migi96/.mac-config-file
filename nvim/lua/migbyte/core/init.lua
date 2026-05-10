require("migbyte.core.options")
require("migbyte.core.keymaps")
-- Capture environment variable
vim.g.neovim_mode = vim.env.NEOVIM_MODE or "default"

-- Delay for `skitty` configuration
if vim.g.neovim_mode == "skitty" then
  vim.wait(500, function()
    return false
  end)
end
