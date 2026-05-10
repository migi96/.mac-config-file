return {
  {
    "zootedb0t/citruszest.nvim",
    lazy = false,    -- Load immediately
    priority = 1000, -- High priority for colorscheme
    config = function()
      -- Configure CitrusZest colorscheme
      require("citruszest").setup({
        option = {
          transparent = false, -- Disable transparency
          bold = true,         -- Enable bold text globally
          italic = true,       -- Enable italic text globally
        },
        style = {
          -- Override specific highlight groups
          Comment = { fg = "#00CC7A", italic = true },  -- Green comments, italicized
          Constant = { fg = "#FFD700", bold = true },   -- Yellow constants, bold
          Identifier = { fg = "#00BFFF", bold = true }, -- Blue identifiers, bold
          Function = { fg = "#FF7431", italic = true }, -- Orange functions, italicized
          Statement = { fg = "#FF1A75", bold = true },  -- Bright red statements, bold
          Visual = { bg = "#404040" },                  -- Background for visual mode
          CursorLine = { bg = "#383838" },              -- Background for cursor line
          PmenuSel = { bg = "#FFD700" },                -- Popup menu selection background
        },
      })

      -- Apply the CitrusZest colorscheme
      vim.cmd("colorscheme citruszest")

      -- Configure Lualine with CitrusZest theme
      local lualine = require("lualine")
      lualine.setup({
        options = {
          theme = "citruszest", -- Use CitrusZest for Lualine
        },
      })

      -- Add custom autocommands for further highlights
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_citruszest", {}),
        pattern = "citruszest",
        callback = function()
          local hl = vim.api.nvim_set_hl
          hl(0, "Normal", { fg = "#BFBFBF", bg = "#121212" })     -- Default text and background
          hl(0, "CursorLineNr", { fg = "#FFD700", bold = true })  -- Highlight line number under cursor
          hl(0, "DiffAdd", { fg = "#1AFFA3", bg = "#121212" })    -- Diff add highlights
          hl(0, "DiffChange", { fg = "#00BFFF", bg = "#121212" }) -- Diff change highlights
          hl(0, "DiffDelete", { fg = "#FF5454", bg = "#121212" }) -- Diff delete highlights
        end,
      })
    end,
  },
}
