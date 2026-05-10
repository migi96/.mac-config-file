return {
  {
    dir = vim.fn.expand("~/.config/nvim/lua/flutter_widget_to_avante"),
    name = "avante-flutter-widget",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("flutter_widget_to_avante").setup({
        -- tmux settings
        tmux = {
          enabled = true,
          pane_scan_lines = 100000,
          -- if your flutter run pane title contains something specific, set it here
          pane_title_match = "flutter run", -- e.g. "flutter"
        },

        -- fallback if tmux detection fails
        vm_service_uri = nil, -- or "ws://127.0.0.1:xxxx/XXXX=/ws"

        -- python helper (use venv python which has websockets installed)
        python = vim.fn.expand("~/.config/nvim/.venv/bin/python3"),
        helper_script = vim.fn.expand("~/.config/nvim/scripts/flutter_widget_inspector.py"),

        -- Avante behavior
        avante = {
          auto_open = true,   -- open chat if closed
          auto_submit = false -- keep in input, don’t auto-send
        },

        -- keymaps
        -- keymaps
        keymaps = {
          append = "<leader>aw",      -- append selected widget to Avante input (once)
          watch_start = "<leader>aW", -- start watch mode (auto append, default limit)
          watch_stop = "<leader>aS",  -- stop watch mode
          watch_prompt = "<leader>S", -- prompt for custom widget limit then start watch
        },

        -- watch mode settings
        watch_interval = 500,     -- polling interval (ms) — higher = less lag
        watch_max_widgets = 5,    -- default max widgets before auto-stop
      })
    end,
  },
}
