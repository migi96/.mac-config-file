return {
  "zbirenbaum/copilot.lua",
  lazy = false,
  priority = 900,
  dependencies = {
    {
      "zbirenbaum/copilot-cmp",
      config = function()
        require("copilot_cmp").setup()
      end,
    },
  },
  config = function()
    require("copilot").setup({
      -- The panel is a nice feature to see multiple suggestions
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
        },
      },
      -- This MUST be disabled to let nvim-cmp handle suggestions
      suggestion = {
        enabled = false,
      },
      -- You can disable Copilot for certain file types
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
      },
    })
  end,
  -- Keymap to open the panel
  keys = {
    {
      "<leader>cco",
      function()
        require("copilot.panel").open()
      end,
      desc = "Open Copilot Panel",
    },
  },
}
