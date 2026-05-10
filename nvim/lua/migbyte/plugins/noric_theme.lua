return {
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,    -- Load the plugin immediately
    priority = 1000, -- Ensure it is loaded first for proper highlighting
    config = function()
      -- Nordic theme setup
      require("nordic").setup({
        -- Customize the base palette if needed
        on_palette = function(palette)
          palette.bg = "#2E3440" -- Modify the background color
          palette.fg = "#D8DEE9" -- Modify the foreground color
        end,
        -- Further customization after palette setup
        after_palette = function(palette)
          palette.blue = "#5E81AC" -- Adjust blue tones
        end,
        -- Customize highlights
        on_highlight = function(highlights, palette)
          highlights.CursorLine = { bg = palette.bg_dark }
          highlights.Visual = { bg = palette.bg_light }
        end,
        -- Enable bold keywords for better readability
        bold_keywords = true,
        -- Enable italic comments for syntax highlighting
        italic_comments = true,
        -- Transparent background options
        transparent = {
          bg = false,    -- Disable transparent background
          float = false, -- Disable transparency for floating windows
        },
        -- Enable brighter borders for floating windows
        bright_border = true,
        -- Reduce blue tones for a softer theme
        reduced_blue = true,
        -- Option to swap background colors
        swap_backgrounds = false,
        -- Cursorline configurations
        cursorline = {
          bold = true,        -- Bold font for cursorline
          bold_number = true, -- Bold cursorline number
          theme = "dark",     -- Cursorline style
          blend = 0.9,        -- Blend cursorline background
        },
        -- Noice plugin integration
        noice = {
          style = "classic", -- Noice style
        },
        -- Telescope plugin integration
        telescope = {
          style = "flat", -- Flat style for Telescope
        },
        -- Leap plugin settings
        leap = {
          dim_backdrop = false, -- Disable backdrop dimming
        },
        -- Treesitter context settings
        ts_context = {
          dark_background = true, -- Enable dark background for Treesitter context
        },
      })

      -- Load the Nordic colorscheme
      require("nordic").load()

      -- Lualine setup for Nordic theme
      require("lualine").setup({
        options = {
          theme = "nordic",
          component_separators = "|",
          section_separators = "",
        },
      })

      -- Expose Nordic color palette for further customizations
      local palette = require("nordic.colors")

      -- Example: Use the palette for custom highlights
      vim.api.nvim_set_hl(0, "Normal", { fg = palette.fg, bg = palette.bg })
      vim.api.nvim_set_hl(0, "Comment", { fg = palette.gray, italic = true })
    end,
  },
}
