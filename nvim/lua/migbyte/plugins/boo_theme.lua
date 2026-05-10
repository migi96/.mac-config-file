return {
  {
    "rockerBOO/boo-colorscheme-nvim",
    lazy = false,    -- Ensure the plugin loads immediately
    priority = 1000, -- Load the colorscheme before other plugins
    config = function()
      -- Customize and configure the Boo colorscheme
      require("boo-colorscheme").use({
        italic = true,           -- Enable italic text for better styling
        theme = "forest_stream", -- Set the desired theme. Options: sunset_cloud, radioactive_waste, forest_stream, crimson_moonlight
      })

      -- Enable `termguicolors` for proper color rendering
      if vim.fn.has("termguicolors") == 1 then
        vim.opt.termguicolors = true
      end

      -- Set up custom highlights for Boo colorscheme
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_boo", {}),
        pattern = "boo",
        callback = function()
          local set_hl = vim.api.nvim_set_hl
          set_hl(0, "Comment", { fg = "#7A8C8B", italic = true })                -- Subtle comments
          set_hl(0, "Keyword", { fg = "#F28D9E", bold = true })                  -- Keywords in bold pink
          set_hl(0, "Function", { fg = "#8EC07C", italic = true })               -- Functions in green with italics
          set_hl(0, "String", { fg = "#D79921" })                                -- Strings in gold
          set_hl(0, "Variable", { fg = "#83A598" })                              -- Variables in teal
          set_hl(0, "Visual", { bg = "#3C3836" })                                -- Visual mode highlight
          set_hl(0, "CursorLine", { bg = "#282828" })                            -- Highlight for current line
          set_hl(0, "PmenuSel", { bg = "#458588", fg = "#EBDBB2", bold = true }) -- Popup menu selection
        end,
      })

      -- Apply the Boo colorscheme
      vim.cmd("colorscheme boo")
    end,
  },
}
