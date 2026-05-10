return {
  {
    "ficcdaf/ashen.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent        = true,
      force_hi_clear     = true,
      style              = {
        bold      = true,
        italic    = true,
        underline = true,
      },
      style_presets      = {
        bold_functions  = true,
        italic_comments = true,
      },
      palette_override   = {
        bg      = "#1E1E1E",
        fg      = "#F5F5F5",
        accent  = "#D08770",
        hint    = "#88C0D0",
        error   = "#BF616A",
        warning = "#EBCB8B",
      },
      terminal_palette   = {
        black   = "#3B4048",
        red     = "#BF616A",
        green   = "#A3BE8C",
        yellow  = "#EBCB8B",
        blue    = "#81A1C1",
        magenta = "#B48EAD",
        cyan    = "#88C0D0",
        white   = "#ECEFF4",
      },
      plugin_integration = {
        telescope   = true,
        lualine     = true,
        cmp         = true,
        trailblazer = true,
        oil         = true,
      },
      highlight_override = {
        Comment     = { fg = "#88C0D0", italic = true },
        Function    = { fg = "#D08770", bold = true },
        String      = { fg = "#A3BE8C", italic = true },
        Variable    = { fg = "#EBCB8B" },
        Conditional = { fg = "#D08770", bold = true },
        Visual      = { bg = "#434C5E" },
        PmenuSel    = { bg = "#5E81AC", fg = "#ECEFF4", bold = true },
        CursorLine  = { bg = "#3B4252" },
      },
    },
    config = function(_, opts)
      require("ashen").setup(opts)
      vim.cmd("colorscheme ashen")
      vim.cmd("highlight Normal     guibg=NONE")
      vim.cmd("highlight NormalFloat guibg=NONE")
    end,
  },
}
