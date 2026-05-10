return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true

      require("catppuccin").setup({
        flavour = "mocha",
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = true,
        term_colors = true,
        dim_inactive = {
          enabled = true,
          shade = "dark",
          percentage = 0.2,
        },
        no_italic = false,
        no_bold = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = { "bold" },
          functions = { "bold", "italic" },
          keywords = { "bold" },
          strings = { "italic" },
          variables = {},
          numbers = {},
          booleans = { "bold" },
          properties = {},
          types = { "italic" },
          operators = {},
        },
        custom_highlights = function(colors)
          return {
            Comment = { fg = colors.flamingo, italic = true },
            Function = { fg = colors.blue, bold = true },
            Keyword = { fg = colors.pink, bold = true },
            String = { fg = colors.green, italic = true },
            Variable = { fg = colors.yellow },
            Visual = { bg = colors.surface0 },
            PmenuSel = { bg = colors.overlay0, fg = colors.text, bold = true },
            CursorLine = { bg = colors.surface0 },
            LineNr = { fg = colors.overlay0 },
            DiagnosticError = { fg = colors.red },
            DiagnosticHint = { fg = colors.teal },
            DiagnosticInfo = { fg = colors.blue },
            DiagnosticWarn = { fg = colors.yellow },
          }
        end,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          telescope = true,
          lualine = false, -- Disable lualine integration
          indent_blankline = {
            enabled = true,
            colored_indent_levels = true,
          },
          neogit = true,
          notify = true,
        },
      })

      vim.cmd("colorscheme catppuccin")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
        },
      })
    end,
  },
}
