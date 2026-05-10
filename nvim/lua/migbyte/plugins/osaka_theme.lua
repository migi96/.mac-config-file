return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,    -- Load immediately
    priority = 1000, -- High priority to load first
    config = function()
      require("solarized-osaka").setup({
        -- Enable transparent background
        transparent = true,

        -- Enable terminal colors
        terminal_colors = true,

        -- Styles configuration for different syntax groups
        styles = {
          comments = { italic = true }, -- Italicize comments
          keywords = { italic = true }, -- Italicize keywords
          functions = {},               -- No special style for functions
          variables = {},               -- No special style for variables
          sidebars = "dark",            -- Dark background for sidebars
          floats = "dark",              -- Dark background for floating windows
        },

        -- Sidebar windows with darker background
        sidebars = { "qf", "help", "vista_kind", "terminal", "packer" },

        -- Adjust brightness of "Day" style
        day_brightness = 0.3,

        -- Hide inactive statusline and replace with thin border
        hide_inactive_statusline = false,

        -- Dim inactive windows
        dim_inactive = false,

        -- Bold section headers in lualine theme
        lualine_bold = false,

        -- Override specific colors in the theme
        on_colors = function(colors)
          colors.hint = colors.orange -- Set "hint" color to orange
          colors.error = "#ff0000"    -- Bright red for errors
        end,

        -- Override highlight groups
        on_highlights = function(hl, colors)
          local prompt = "#2d3149" -- Define a custom prompt background color

          hl.TelescopeNormal = {
            bg = colors.bg_dark,
            fg = colors.fg_dark,
          }
          hl.TelescopeBorder = {
            bg = colors.bg_dark,
            fg = colors.bg_dark,
          }
          hl.TelescopePromptNormal = {
            bg = prompt,
          }
          hl.TelescopePromptBorder = {
            bg = prompt,
            fg = prompt,
          }
          hl.TelescopePromptTitle = {
            bg = prompt,
            fg = prompt,
          }
          hl.TelescopePreviewTitle = {
            bg = colors.bg_dark,
            fg = colors.bg_dark,
          }
          hl.TelescopeResultsTitle = {
            bg = colors.bg_dark,
            fg = colors.bg_dark,
          }
        end,
      })

      -- Load the colorscheme
      vim.cmd([[colorscheme solarized-osaka]])

      -- Optional: Lualine setup for Solarized Osaka
      require("lualine").setup({
        options = {
          theme = "solarized-osaka", -- Use Solarized Osaka as the theme
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
          globalstatus = true,
        },
      })

      -- Optional: Telescope customization example
      require("telescope").setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➤ ",
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
        },
      })
    end,
  },
}
