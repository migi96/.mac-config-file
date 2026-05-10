-- lua/migbyte/plugins/mini-surround.lua
-- Full configuration for mini.surround with 'gs' as the add-surround shortcut
return {
  "echasnovski/mini.nvim",
  branch = "stable",
  config = function()
    require("mini.surround").setup({
      -- Override default mappings; use "gs" to add surroundings
      mappings = {
        jadd           = "gs", -- Add surrounding
        delete         = "ds", -- Delete surroundingj
        find           = "sf", -- Find surrounding (to the right)
        find_left      = "sF", -- Find surrounding (to the left)
        highlight      = "sh", -- Highlight surrounding
        replace        = "cs", -- Change surrounding
        update_n_lines = "gS", -- Update number of surrounding lines
      },
    })
  end,
}
