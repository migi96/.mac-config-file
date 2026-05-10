return {
  "JDev-The-Dev/barreler.nvim",
  keys = {
    {
      "<leader>ex",
      "<cmd>Barreler<CR>",
      mode = "n",
      desc = "Barreler: Create barrel file for current layer",
    },
  },
  opts = {
    barreler_file = "index.dart",
    template = "export './${dir}${name}${ext}';",
    exclude = { "index.dart", ".*.g.dart", ".*.freezed.dart" },
    recursive = false,
  },
}
