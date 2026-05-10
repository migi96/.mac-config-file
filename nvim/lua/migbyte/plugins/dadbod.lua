return {
  {
    "tpope/vim-dadbod",
    lazy = true,
    keys = {
      -- Prompt for a database name and create it
      {
        "<leader>dc",
        function()
          vim.ui.input({ prompt = "New DB name: " }, function(input)
            if input and #input > 0 then
              vim.cmd("DB create " .. input)
            end
          end)
        end,
        desc = "Create new database",
      },
    },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = { "tpope/vim-dadbod" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_help = 0
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_execute_on_save = 0
    end,
    keys = {
      { "<leader>dt", "<cmd>DBUIToggle<cr>",        desc = "Toggle DB UI" },
      { "<leader>dl", "<cmd>DBUIFindBuffer<cr>",    desc = "Find DB Buffer" },
      { "<leader>da", "<cmd>DBUIAddConnection<cr>", desc = "Add DB Connection" },
    },
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
    dependencies = { "tpope/vim-dadbod" },
    config = function()
      vim.g.db_completion_enable = 1
    end,
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
  },
}
