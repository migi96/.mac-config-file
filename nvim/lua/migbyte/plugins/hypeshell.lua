return {
  name = "hypeshell",
  dir = vim.fn.expand("~/.hypeshell/nvim"),
  config = function()
    require("hypeshell").setup()
  end,
}
