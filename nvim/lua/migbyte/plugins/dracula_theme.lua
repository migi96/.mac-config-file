return {
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Load and configure the Dracula theme
      local dracula = require("dracula")
      dracula.setup({
        -- Customize Dracula color palette
        colors = {
          bg = "#282A36",
          fg = "#F8F8F2",
          selection = "#44475A",
          comment = "#6272A4",
          red = "#FF5555",
          orange = "#FFB86C",
          yellow = "#F1FA8C",
          green = "#50fa7b",
          purple = "#BD93F9",
          cyan = "#8BE9FD",
          pink = "#FF79C6",
          bright_red = "#FF6E6E",
          bright_green = "#69FF94",
          bright_yellow = "#FFFFA5",
          bright_blue = "#D6ACFF",
          bright_magenta = "#FF92DF",
          bright_cyan = "#A4FFFF",
          bright_white = "#FFFFFF",
          menu = "#21222C",
          visual = "#3E4452",
          gutter_fg = "#4B5263",
          nontext = "#3B4048",
          white = "#ABB2BF",
          black = "#191A21",
        },
        -- Theme options
        show_end_of_buffer = true,    -- Show '~' characters at buffer end
        transparent_bg = true,        -- Use transparent background
        lualine_bg_color = "#44475a", -- Set lualine background color
        italic_comment = true,        -- Enable italic comments
        -- Override highlights
        overrides = {
          -- Example override: NonText highlight
          NonText = { fg = "#6272A4" },
        },
      })

      -- Load the theme
      vim.cmd([[colorscheme dracula]])

      -- Optional: Configure lualine to use Dracula theme
      require("lualine").setup({
        options = {
          theme = "dracula-nvim",
        },
      })
    end,
  },
}
