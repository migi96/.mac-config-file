return {
  {
    'luisiacc/gruvbox-baby',
    lazy = false,
    priority = 1000,
    config = function()
      -- Configuration for Gruvbox Baby
      vim.g.gruvbox_baby_function_style = "NONE"    -- No special styling for functions
      vim.g.gruvbox_baby_keyword_style = "italic"   -- Italicize keywords
      vim.g.gruvbox_baby_comment_style = "italic"   -- Italicize comments
      vim.g.gruvbox_baby_string_style = "nocombine" -- Default styling for strings
      vim.g.gruvbox_baby_variable_style = "NONE"    -- No special styling for variables

      -- Custom highlight groups
      vim.g.gruvbox_baby_highlights = {
        Normal = { fg = "#ebdbb2", bg = "NONE", style = "NONE" },    -- Default text
        Comment = { fg = "#928374", bg = "NONE", style = "italic" }, -- Italicized comments
        Keyword = { fg = "#d79921", bg = "NONE", style = "italic" }, -- Italicized keywords
        String = { fg = "#b8bb26", bg = "NONE", style = "NONE" },    -- Default styling for strings
        Function = { fg = "#fabd2f", bg = "NONE", style = "NONE" },  -- Default styling for functions
      }

      vim.g.gruvbox_baby_telescope_theme = 1  -- Enable the telescope theme
      vim.g.gruvbox_baby_transparent_mode = 1 -- Enable transparent background

      -- Load the Gruvbox Baby colorscheme
      vim.cmd("colorscheme gruvbox-baby")
    end,
  }



}
