return {
  "kndndrj/nvim-dbee",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    -- let dbee try to detect curl/wget/go/etc.
    require("dbee").install()
  end,
  config = function()
    -- basic setup (you can pass opts here)
    require("dbee").setup()

    -- map <leader>db to open DBee
    vim.keymap.set(
      "n",
      "<leader>db",
      function() require("dbee").open() end,
      { desc = "󱩚 Open DBee" }
    )
  end,

}
