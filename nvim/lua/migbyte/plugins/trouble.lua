return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {
    focus = true,
    position = "right",
    size = { width = 50 },
    auto_preview = false,
    signs = {
      error = "",
      warning = "",
      hint = "💡",
      information = "",
    },
    actions = {
      ['a'] = 'code_action',
      ['r'] = 'fix',
    },
    -- auto_open = true, -- Uncomment to enable automatic opening
    -- auto_close = true, -- Uncomment to enable automatic closing
  },
  cmd = "Trouble",
  keys = {
    -- Toggles for various lists
    { "<leader>nt", "<cmd>Trouble diagnostics toggle<CR>",              desc = "Toggle workspace diagnostics" },
    { "<leader>ns", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Toggle document diagnostics" },
    { "<leader>xt", "<cmd>Trouble quickfix toggle<CR>",                 desc = "Toggle quickfix list" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<CR>",                  desc = "Toggle location list" },
    { "<leader>xd", "<cmd>Trouble todo toggle<CR>",                     desc = "Toggle todos" },

    -- Navigation for diagnostics
    {
      "]d",
      function() require("trouble").next({ skip_groups = true, jump = true }); end,
      desc = "Next diagnostic",
    },
    {
      "[d",
      function() require("trouble").prev({ skip_groups = true, jump = true }); end,
      desc = "Previous diagnostic",
    },
    {
      "]e",
      function() require("trouble").next({ mode = "diagnostics", severity = vim.diagnostic.severity.ERROR, skip_groups = true, jump = true }); end,
      desc = "Next error",
    },
    {
      "[e",
      function() require("trouble").prev({ mode = "diagnostics", severity = vim.diagnostic.severity.ERROR, skip_groups = true, jump = true }); end,
      desc = "Previous error",
    },

    -- Code Exploration
    { "<leader>nr", "<cmd>Trouble lsp_references<CR>",              desc = "LSP references" },
    { "<leader>na", "<cmd>Trouble symbols toggle<CR>",              desc = "Workspace symbols" },
    { "<leader>nd", "<cmd>Trouble symbols toggle filter.buf=0<CR>", desc = "Document symbols" },
  },
}
