return {
  {
    "fcancelinha/nordern.nvim",
    branch = "master",
    priority = 1000,
    lazy = false,                   -- Ensure the plugin loads immediately
    opts = {
      brighter_comments = true,     -- Brighter comments for better readability
      brighter_conditionals = true, -- Use aurora yellow for conditionals
      italic_comments = true,       -- Italicize comments for better syntax differentiation
      transparent = false,          -- Disable transparency for consistent background
    },
    config = function()
      -- Apply Nordern.nvim setup with custom options
      require("nordern").setup({
        brighter_comments = true,     -- Enable brighter comments
        brighter_conditionals = true, -- Highlight conditionals in aurora yellow
        italic_comments = true,       -- Enable italic styling for comments
        transparent = false,          -- Keep the background opaque
      })

      -- Set the colorscheme
      vim.cmd("colorscheme nordern")

      -- Set up custom highlights for Nordern.nvim
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_nordern", {}),
        pattern = "nordern",
        callback = function()
          local set_hl = vim.api.nvim_set_hl
          set_hl(0, "Comment", { fg = "#8E9CAB", italic = true })                -- Comments in brighter blue-gray
          set_hl(0, "Keyword", { fg = "#EBCB8B", bold = true })                  -- Keywords in aurora yellow
          set_hl(0, "Function", { fg = "#88C0D0", italic = true })               -- Functions in cyan
          set_hl(0, "String", { fg = "#A3BE8C" })                                -- Strings in green
          set_hl(0, "Variable", { fg = "#D8DEE9" })                              -- Variables in white
          set_hl(0, "Conditional", { fg = "#EBCB8B", bold = true })              -- Conditionals in aurora yellow
          set_hl(0, "Visual", { bg = "#434C5E" })                                -- Visual selection background
          set_hl(0, "CursorLine", { bg = "#3B4252" })                            -- Highlight for the current line
          set_hl(0, "PmenuSel", { bg = "#4C566A", fg = "#ECEFF4", bold = true }) -- Popup menu selection
          set_hl(0, "TelescopeBorder", { fg = "#4C566A" })                       -- Telescope border
          set_hl(0, "TelescopePrompt", { bg = "#3B4252", fg = "#D8DEE9" })       -- Telescope prompt
          set_hl(0, "TelescopeResults", { bg = "#2E3440", fg = "#ECEFF4" })      -- Telescope results
        end,
      })

      -- Set up Lualine with Nordern theme
      require("lualine").setup({
        options = {
          theme = "nordern",
          icons_enabled = true,
          component_separators = "|",
          section_separators = "",
        },
      })

      -- Additional plugin support (optional customization)
      -- Customize bufferline colors
      require("bufferline").setup({
        options = {
          separator_style = "thin",
          diagnostics = "nvim_lsp",
        },
      })

      -- Configure NvimTree for Nordern
      require("nvim-tree").setup({
        renderer = {
          highlight_opened_files = "all",
          root_folder_modifier = ":~",
        },
        filters = {
          dotfiles = false,
        },
      })

      -- Additional plugin integration for Telescope, Treesitter, etc.
      require("telescope").setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
        },
      })

      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
}
