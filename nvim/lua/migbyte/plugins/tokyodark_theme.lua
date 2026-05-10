-- plugins/tokyodark.lua
return {
  {
    "tiagovla/tokyodark.nvim",
    lazy = true, -- don't load (and apply) on startup
    opts = {
      transparent_background = false,
      gamma                  = 1.00,
      styles                 = {
        comments    = { italic = true },
        keywords    = { italic = true },
        identifiers = { italic = true },
        functions   = {},
        variables   = {},
      },
      custom_highlights      = function(highlights, palette)
        highlights.Comment    = { fg = palette.gray, italic = true }
        highlights.Keyword    = { fg = palette.magenta, bold = true }
        highlights.Function   = { fg = palette.blue }
        highlights.Identifier = { fg = palette.cyan, italic = true }
        highlights.Variable   = { fg = palette.orange }
        return highlights
      end,
      custom_palette         = function(palette)
        palette.gray    = "#4A4A4A"
        palette.magenta = "#D16D9E"
        palette.blue    = "#569CD6"
        palette.cyan    = "#4EC9B0"
        palette.orange  = "#D19A66"
        return palette
      end,
      terminal_colors        = true,
    },
    config = function(_, opts)
      -- only set up the theme, do NOT call `colorscheme` here
      require("tokyodark").setup(opts)
    end,
  },
}
