return {
  {
    "kevinm6/kurayami.nvim",
    -- Load immediately so `require("kurayami")` always works
    lazy     = false,
    priority = 1000,
    config   = function()
      require("kurayami").setup({
        override = {
          Comment          = { fg = "#7C7C7C", italic = true },
          Keyword          = { fg = "#D87F57", bold = true },
          Function         = { fg = "#FFB86C", bold = true },
          String           = { fg = "#99C794", italic = true },
          Number           = { fg = "#FFD700", bg = "NONE", bold = true },
          Boolean          = { fg = "#FF6E6E", bold = true },
          Variable         = { fg = "#76C6FF" },
          Conditional      = { fg = "#EBCB8B", bold = true },
          Visual           = { bg = "#4C566A" },
          CursorLine       = { bg = "#3B4252" },
          PmenuSel         = { bg = "#5E81AC", fg = "#ECEFF4", bold = true },
          TelescopeBorder  = { fg = "#4C566A" },
          TelescopePrompt  = { bg = "#3B4252", fg = "#D8DEE9" },
          TelescopeResults = { bg = "#2E3440", fg = "#ECEFF4" },
        },
        plugins = {
          treesitter  = true,
          telescope   = true,
          nvim_tree   = true,
          lualine     = true,
          bufferline  = true,
          gitsigns    = true,
          nvim_cmp    = true,
          nvim_notify = true,
        },
        options = {
          transparent = false,
        },
      })
      vim.cmd("colorscheme kurayami")
    end,
  },
}
