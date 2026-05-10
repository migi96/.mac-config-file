return {
  {
    "neanias/everforest-nvim",
    lazy = false,
    priority = 1000, -- Ensure it loads before other plugins
    config = function()
      require("everforest").setup({
        background = "dark",               -- Set background mode
        transparent_background = false,    -- Disable transparent background
        dim_inactive_windows = true,       -- Dim inactive windows
        disable_italic_comments = false,   -- Enable italic comments
        enable_italic = true,              -- Enable general italic styling
        cursor = "block",                  -- Use block cursor style
        sign_column_background = "none",   -- Keep sign column transparent
        spell_foreground = "underline",    -- Use underline for spell-checking errors
        ui_contrast = "high",              -- High contrast for UI elements
        show_eob = false,                  -- Hide '~' characters at the end of buffers
        current_word = "underline",        -- Underline the current word
        diagnostic_text_highlight = true,  -- Enable diagnostic text highlight
        diagnostic_line_highlight = false, -- Disable line-level diagnostic highlights
        diagnostic_virtual_text = true,    -- Show virtual text for diagnostics
        disable_terminal_colours = false,  -- Enable terminal colors
        colours_override = function(palette)
          -- Example of overriding a palette color
          palette.red = "#b86466"
        end,
        on_highlights = function(hl, palette)
          -- Customize highlight groups
          hl.DiagnosticError = { fg = palette.red, bg = palette.none, sp = palette.red }
          hl.DiagnosticWarn = { fg = palette.yellow, bg = palette.none, sp = palette.yellow }
          hl.DiagnosticInfo = { fg = palette.blue, bg = palette.none, sp = palette.blue }
          hl.DiagnosticHint = { fg = palette.green, bg = palette.none, sp = palette.green }

          -- Example of bold styling for TSBoolean
          hl.TSBoolean = { fg = palette.purple, bg = palette.none, bold = true }
        end,
      })

      -- Load the colorscheme
      vim.cmd([[colorscheme everforest]])
    end,
  },
}
