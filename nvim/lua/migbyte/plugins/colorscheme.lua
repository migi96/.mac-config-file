return {
  -- Add Nightfox theme
  {
    "EdenEast/nightfox.nvim",
    priority = 1000, -- ensure this loads before other plugins
    config = function()
      require("nightfox").setup({
        options = {
          transparent = false,    -- Disable setting the background
          terminal_colors = true, -- Enable terminal colors
          dim_inactive = false,   -- Keep inactive panes the same background
          module_default = true,  -- Enable default settings for all modules
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
          },
        },
      })
    end,
  },

  -- Add Feline for the statusline
  {
    "famiu/feline.nvim",
    config = function()
      local feline = require("feline")
      local nightfox = require("nightfox.palette").load("nordfox")

      -- Define the theme
      local theme = {
        bg = nightfox.bg1,
        fg = nightfox.fg1,
      }

      -- Define components for the statusline
      local components = {
        active = {
          {
            {
              provider = "vi_mode",
              hl = function()
                return {
                  name = require("feline.providers.vi_mode").get_mode_highlight_name(),
                  fg = theme.fg,
                  bg = theme
                      .bg
                }
              end,
            },
            {
              provider = "file_info",
              hl = { fg = theme.fg, bg = theme.bg },
            },
          },
          {
            {
              provider = "position",
              hl = { fg = theme.fg, bg = theme.bg },
            },
          },
        },
        inactive = {
          {
            {
              provider = "file_info",
              hl = { fg = theme.fg, bg = theme.bg },
            },
          },
        },
      }

      -- Set up Feline
      feline.setup({
        theme = theme,
        components = components,
      })
    end,
  },

  -- Add Tabby for the tabline
  {
    "nanozuki/tabby.nvim",
    config = function()
      local nightfox = require("nightfox.palette").load("nordfox")
      require("tabby").setup({
        tabline = {
          hl = { fg = nightfox.fg1, bg = nightfox.bg1 },
          layout = "active_wins_at_tail",
          head = {
            { "  ", hl = { fg = nightfox.fg0, bg = nightfox.bg3, style = "bold" } },
            { "▏", hl = { fg = nightfox.bg3, bg = nightfox.bg3 } },
          },
          active_tab = {
            label = function(tabid)
              return {
                "  " .. vim.api.nvim_tabpage_get_number(tabid) .. " ",
                hl = { fg = nightfox.bg0, bg = nightfox.blue, style = "bold" },
              }
            end,
            left_sep = { "▏", hl = { fg = nightfox.blue, bg = nightfox.bg3 } },
            right_sep = { "▏", hl = { fg = nightfox.blue, bg = nightfox.bg3 } },
          },
          inactive_tab = {
            label = function(tabid)
              return {
                "  " .. vim.api.nvim_tabpage_get_number(tabid) .. " ",
                hl = { fg = nightfox.fg1, bg = nightfox.bg1 },
              }
            end,
            left_sep = { "▏", hl = { fg = nightfox.bg1, bg = nightfox.bg3 } },
            right_sep = { "▏", hl = { fg = nightfox.bg1, bg = nightfox.bg3 } },
          },
          tail = {
            { "▏", hl = { fg = nightfox.bg3, bg = nightfox.bg3 } },
          },
        },
      })
    end,
  },
}
