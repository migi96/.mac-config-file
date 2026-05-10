return {
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
    config = function()
      -- Set up a keybinding to lazy-load and run Typr
      vim.api.nvim_set_keymap(
        "n",                              -- Normal mode
        "<leader>bj",                     -- Shortcut key
        ":Typr<CR>",                      -- Command to execute
        { noremap = true, silent = true } -- Keybinding options
      )
    end,
    keys = { { "<leader>bj", ":Typr<CR>", desc = "Open Typr typing practice" } }, -- Ensure lazy loading on keypress
  },
}
