return {
  {
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("bamboo").setup({
        -- Main options
        style = "vulgaris",                                       -- Options: 'vulgaris' (regular), 'multiplex' (greener), 'light'
        toggle_style_key = "<leader>ts",                          -- Keybind to toggle theme styles
        toggle_style_list = { "vulgaris", "multiplex", "light" }, -- List of styles to toggle
        transparent = false,                                      -- Enable/Disable transparency
        dim_inactive = true,                                      -- Dim inactive windows/buffers
        term_colors = true,                                       -- Apply theme colors to terminal
        ending_tildes = true,                                     -- Show end-of-buffer tildes
        cmp_itemkind_reverse = false,                             -- Default item kind highlights in cmp menu

        -- Code styling
        code_style = {
          comments = { italic = true },     -- Italicize comments
          conditionals = { italic = true }, -- Italicize conditionals
          keywords = { bold = true },       -- Bold keywords
          functions = { italic = true },    -- Italicize functions
          namespaces = { italic = true },   -- Italicize namespaces
          parameters = {},                  -- Default style for parameters
          strings = {},                     -- Default style for strings
          variables = {},                   -- Default style for variables
        },

        -- Lualine options
        lualine = {
          transparent = false, -- Disable transparency in Lualine
        },

        -- Diagnostics options
        diagnostics = {
          darker = true,     -- Use darker colors for diagnostics
          undercurl = true,  -- Use undercurl for diagnostics
          background = true, -- Enable background for virtual text
        },

        -- Custom colors
        colors = {
          bright_orange = "#ff8800", -- Define a new color
          green = "#00ffaa",         -- Override green
        },

        -- Custom highlights
        highlights = {
          ["@comment"] = { fg = "$grey" },                                      -- Subtle comment color
          ["@keyword"] = { fg = "$green", bold = true },                        -- Green bold keywords
          ["@string"] = { fg = "$bright_orange", bg = "#303030", bold = true }, -- Orange strings
          ["@function"] = { fg = "#00aaff", italic = true, underline = true },  -- Blue italicized functions
          ["@function.builtin"] = { fg = "#0059ff" },                           -- Light blue for built-in functions
        },
      })

      -- Load the Bamboo theme
      require("bamboo").load()
    end,
  },
}
