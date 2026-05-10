return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  priority = 1000,
  -- make WhichKey pop up quickly
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  -- v3-style setup -------------------------------------------------------
  opts = {
    ----------------------------------------------------------------------
    -- core UI / behaviour
    ----------------------------------------------------------------------
    plugins = {
      marks     = true,
      registers = true,
    },
    replace = { ["<leader>"] = "Leader" }, -- was key_labels in v2
    win     = { no_overlap = true },       -- keep the floating window clear
    ----------------------------------------------------------------------
    -- ⌨️  mapping *spec*
    ----------------------------------------------------------------------
    spec    = {
      --------------------------------------------------------------------
      -- General helpers
      --------------------------------------------------------------------
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer-local keymaps",
      },
      --------------------------------------------------------------------
      -- Laravel groups (fixed old-spec warning)
      --------------------------------------------------------------------
      { "<leader>lv",   group = "Laravel" },
      { "<leader>lm",   group = "Laravel-Make" },
      --------------------------------------------------------------------
      -- Jira Pipeline (multi-project)
      --------------------------------------------------------------------
      { "<leader>j",    group = "Jira" },
      { "<leader>jp",   desc = "Pick Ticket (Multi-Project)" },
      { "<leader>jc",   desc = "Create Issue (Project Picker)" },
      { "<leader>ji",   desc = "View Issue Detail (Float)" },
      { "<leader>jw",   desc = "Edit Issue (:w syncs to Jira)" },
      { "<leader>jv",   desc = "View Issue (upstream)" },
      { "<leader>ja",   desc = "Send to Avante" },
      { "<leader>jf",   desc = "Show Session Float" },
      { "<leader>jx",   desc = "End Session + Log Time" },
      { "<leader>jt",   desc = "Transition Status (Picker)" },
      { "<leader>jd",   desc = "Test Connection + List Projects" },
      --------------------------------------------------------------------
      -- Harpoon
      --------------------------------------------------------------------
      { "<leader>h",    group = "Harpoon" },
      -- "Navigate" subgroup – we *hide* the bare <leader>ho prefix so
      -- it doesn't show up (or overlap) in the health check.
      { "<leader>ho",   group = "Navigate",                                       hidden = true },
      -- numbered files
      { "<leader>ho1",  "<cmd>lua require('harpoon.ui').nav_file(1)<cr>",         desc = "File 1" },
      { "<leader>ho2",  "<cmd>lua require('harpoon.ui').nav_file(2)<cr>",         desc = "File 2" },
      { "<leader>ho3",  "<cmd>lua require('harpoon.ui').nav_file(3)<cr>",         desc = "File 3" },
      { "<leader>ho4",  "<cmd>lua require('harpoon.ui').nav_file(4)<cr>",         desc = "File 4" },
      { "<leader>ho5",  "<cmd>lua require('harpoon.ui').nav_file(5)<cr>",         desc = "File 5" },
      { "<leader>ho6",  "<cmd>lua require('harpoon.ui').nav_file(6)<cr>",         desc = "File 6" },
      { "<leader>ho7",  "<cmd>lua require('harpoon.ui').nav_file(7)<cr>",         desc = "File 7" },
      { "<leader>ho8",  "<cmd>lua require('harpoon.ui').nav_file(8)<cr>",         desc = "File 8" },
      { "<leader>ho9",  "<cmd>lua require('harpoon.ui').nav_file(9)<cr>",         desc = "File 9" },
      { "<leader>ho10", "<cmd>lua require('harpoon.ui').nav_file(10)<cr>",        desc = "File 10" },
      { "<leader>ho11", "<cmd>lua require('harpoon.ui').nav_file(11)<cr>",        desc = "File 11" },
      -- actions
      { "<leader>hk",   "<cmd>lua require('harpoon.mark').add_file()<cr>",        desc = "Add file" },
      { "<leader>hr",   "<cmd>lua require('harpoon.mark').rm_file()<cr>",         desc = "Remove" },
      { "<leader>he",   "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "Toggle UI" },
      { "<leader>hn",   "<cmd>lua require('harpoon.ui').nav_next()<cr>",          desc = "Next file" },
      { "<leader>hp",   "<cmd>lua require('harpoon.ui').nav_prev()<cr>",          desc = "Prev file" },
    },
  },
}
