return {
  {
    "Yazeed1s/minimal.nvim",
    lazy = false,    -- Load the theme immediately
    priority = 1000, -- Ensure it's loaded early for other plugin integration
    config = function()
      -- Configuration options before loading the colorscheme
      vim.g.minimal_italic_comments = true         -- Enable italic comments
      vim.g.minimal_italic_keywords = true         -- Enable italic keywords
      vim.g.minimal_italic_booleans = true         -- Enable italic booleans
      vim.g.minimal_italic_functions = true        -- Enable italic functions
      vim.g.minimal_italic_variables = false       -- Disable italic variables
      vim.g.minimal_transparent_background = false -- Keep the background opaque

      -- Set custom highlights for the colorscheme
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_minimal", {}),
        pattern = "minimal",
        callback = function()
          local set_hl = vim.api.nvim_set_hl
          set_hl(0, "Comment", { fg = "#6272a4", italic = true })                -- Comments in blue with italic
          set_hl(0, "Keyword", { fg = "#ff79c6", bold = true, italic = true })   -- Keywords in pink with bold and italic
          set_hl(0, "Function", { fg = "#50fa7b", bold = true, italic = true })  -- Functions in green with bold and italic
          set_hl(0, "String", { fg = "#f1fa8c", italic = true })                 -- Strings in yellow with italic
          set_hl(0, "Variable", { fg = "#8be9fd" })                              -- Variables in cyan
          set_hl(0, "Number", { fg = "#bd93f9", bold = true })                   -- Numbers in purple with bold
          set_hl(0, "Boolean", { fg = "#ff5555", bold = true, italic = true })   -- Booleans in red with bold and italic
          set_hl(0, "Conditional", { fg = "#ffb86c", bold = true })              -- Conditionals in orange with bold
          set_hl(0, "Visual", { bg = "#44475a" })                                -- Visual selection background
          set_hl(0, "CursorLine", { bg = "#282a36" })                            -- Current line highlight
          set_hl(0, "PmenuSel", { bg = "#50fa7b", fg = "#282a36", bold = true }) -- Popup menu selection
          set_hl(0, "TelescopeBorder", { fg = "#6272a4" })                       -- Telescope border in blue
          set_hl(0, "TelescopePrompt", { bg = "#282a36", fg = "#f8f8f2" })       -- Telescope prompt
          set_hl(0, "TelescopeResults", { bg = "#44475a", fg = "#f8f8f2" })      -- Telescope results
        end,
      })

      -- Load the colorscheme
      vim.cmd([[colorscheme minimal]])
    end,
  },
}
