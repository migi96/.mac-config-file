return {
  {
    "ricardoramirezr/blade-nav.nvim",
    -- any completion plugin you use (optional)
    dependencies = {
      "hrsh7th/nvim-cmp",                    -- for nvim-cmp source
      { "ms-jpq/coq_nvim", branch = "coq" }, -- for coq source
    },
    ft = { "blade", "php" },                 -- only load when editing Blade/PHP
    opts = {
      close_tag_on_complete = true,          -- default: true
    },
    config = function(_, opts)
      require("blade-nav").setup(opts)
    end,
  },
}
