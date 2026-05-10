-- lua/migbyte/plugins/mini-files.lua
-- Full configuration for mini.files explorer with correct <leader> mapping

-- Make sure leader is set before any <leader> mappings
vim.g.mapleader = " "

return {
  "echasnovski/mini.nvim",
  branch = "stable",
  config = function()
    -- Setup the mini.files module
    require("mini.files").setup({
      -- What to show and in which order
      content = {
        filter = nil, -- no additional filtering
        prefix = nil, -- default prefixes
        sort   = nil, -- default sort order
      },

      -- Keybindings *inside* the file explorer
      mappings = {
        close       = "q",
        go_in       = "l",
        go_in_plus  = "L",
        go_out      = "h",
        go_out_plus = "H",
        mark_goto   = "'",
        mark_set    = "m",
        reset       = "<BS>",
        reveal_cwd  = "@",
        show_help   = "g?",
        synchronize = "=",
        trim_left   = "<",
        trim_right  = ">",
      },

      -- General behavior options
      options = {
        permanent_delete        = true, -- delete files permanently
        use_as_default_explorer = true, -- override :Ex, netrw, etc.
      },

      -- Window layout settings
      windows = {
        max_number    = math.huge, -- no limit
        preview       = true,      -- show preview pane
        width_focus   = 50,
        width_nofocus = 15,
        width_preview = 25,
      },
    })

    -- Map <Space>ml to toggle the file explorer
    vim.keymap.set(
      "n",
      "<leader>ml",
      require("mini.files").open,
      { desc = "Toggle MiniFiles Explorer", silent = true }
    )
  end,
}
