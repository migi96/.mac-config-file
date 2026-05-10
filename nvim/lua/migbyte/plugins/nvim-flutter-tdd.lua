return {
  {
    "Uniyo-Ltd/nvim-flutter-tdd",
    config = function(_, opts)
      local flutter_tdd = require("flutter-tdd")
      flutter_tdd.setup(opts)

      -- Keybinding for creating test files
      vim.keymap.set("n", "<leader>ct", ":CreateTest<CR>", { desc = "Create Flutter test file" })
    end,
  },
}
