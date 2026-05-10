return {

  {
    'mhartington/oceanic-next',
    lazy = false,
    priority = 1000,
    config = function()
      -- Enable true colors for proper rendering
      vim.opt.termguicolors = true

      -- Enable bold and italic styles
      vim.g.oceanic_next_terminal_bold = 1
      vim.g.oceanic_next_terminal_italic = 1

      -- Custom highlights for transparency (optional)
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_oceanic_next", {}),
        pattern = "OceanicNext",
        callback = function()
          local set_hl = vim.api.nvim_set_hl
          set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })      -- Transparent background
          set_hl(0, "LineNr", { bg = "NONE", ctermbg = "NONE" })      -- Transparent line numbers
          set_hl(0, "SignColumn", { bg = "NONE", ctermbg = "NONE" })  -- Transparent sign column
          set_hl(0, "EndOfBuffer", { bg = "NONE", ctermbg = "NONE" }) -- Transparent end of buffer
          set_hl(0, "Comment", { fg = "#65737E", italic = true })     -- Italicized comments
          set_hl(0, "Keyword", { fg = "#C594C5", bold = true })       -- Bold keywords
          set_hl(0, "Function", { fg = "#6699CC", italic = true })    -- Italicized functions
          set_hl(0, "String", { fg = "#99C794" })                     -- Strings in green
          set_hl(0, "Visual", { bg = "#4F5B66" })                     -- Visual selection background
          set_hl(0, "CursorLine", { bg = "#343D46" })                 -- Highlight current line
          set_hl(0, "PmenuSel", { bg = "#6699CC", fg = "#FFFFFF" })   -- Popup menu selection
        end,
      })

      -- Set airline theme if installed
      if vim.fn.exists("g:airline_theme") then
        vim.g.airline_theme = "oceanicnext"
      end

      -- Apply the OceanicNext theme
      vim.cmd("colorscheme OceanicNext")
    end,
  }

}
