return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = function()
      require("flutter-tools").setup {
        ui                 = {
          border = "rounded",
          notification_style = "native",
        },
        decorations        = {
          statusline = { app_version = false, device = false, project_config = false },
        },
        debugger           = { enabled = false },
        flutter_path       = nil, -- override if needed
        flutter_lookup_cmd = nil,
        fvm                = false,
        widget_guides      = { enabled = true },
        closing_tags       = { enabled = true, prefix = ">", highlight = "ErrorMsg", priority = 10 },
        dev_log            = { enabled = true, open_cmd = "15split", focus_on_open = true },
        dev_tools          = { autostart = false, auto_open_browser = false },
        outline            = { open_cmd = "30vnew", auto_open = false },
        lsp                = {
          on_attach    = function(_, bufnr) end,
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          settings     = {
            showTodos               = true,
            completeFunctionCalls   = true,
            analysisExcludedFolders = {},
            renameFilesWithClasses  = "prompt",
            enableSnippets          = true,
            updateImportsOnRename   = true,
          },
        },
      }
    end,
  },
}
