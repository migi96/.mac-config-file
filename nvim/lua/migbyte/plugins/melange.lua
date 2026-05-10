return {
  {
    "savq/melange-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Enable `termguicolors` for proper colors
      vim.opt.termguicolors = true

      -- Load the Melange colorscheme
      vim.cmd.colorscheme("melange")

      -- Additional configuration for light/dark variants
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("melange_customization", {}),
        pattern = "melange",
        callback = function()
          local bg = vim.opt.background:get()
          if bg == "light" then
            -- Adjust settings for the light variant
            vim.opt.background = "light"
          else
            -- Adjust settings for the dark variant
            vim.opt.background = "dark"
          end
        end,
      })

      -- Plugin-specific customizations
      require("lualine").setup({
        options = {
          theme = "melange",
        },
      })

      -- Treesitter and plugin highlights
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true, -- Enable treesitter highlights
          additional_vim_regex_highlighting = false,
        },
      })

      -- Define custom highlights if necessary
      vim.api.nvim_set_hl(0, "Normal", { bg = "none", fg = "#d4be98" })
      vim.api.nvim_set_hl(0, "Comment", { fg = "#928374", italic = true })
      vim.api.nvim_set_hl(0, "Keyword", { fg = "#d79921", bold = true })
      vim.api.nvim_set_hl(0, "Function", { fg = "#83a598", italic = true })
      vim.api.nvim_set_hl(0, "String", { fg = "#b8bb26", bold = true })
      vim.api.nvim_set_hl(0, "Variable", { fg = "#fabd2f" })

      -- Terminal emulator-specific settings
      -- Support for Alacritty, Kitty, Wezterm, iTerm2, and others
      vim.g.melange_termcolors = true
    end,
  },
}
