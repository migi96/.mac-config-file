-- lua/migbyte/plugins/tagonaut.lua
return {
  'sulring/tagonaut.nvim',
  -- Lazy-load only once you have a real file in the buffer:
  event = { 'BufReadPost', 'BufNewFile' },

  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    -- Safe-wrap the setup so errors get notified, not crash Neovim
    local ok, err = pcall(function()
      require('tagonaut').setup({
        config_file      = vim.fn.stdpath("data") .. "/tagonauts.json",
        use_devicons     = pcall(require, "nvim-web-devicons"),
        auto_assign_keys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
        use_lsp          = true,
        use_treesitter   = true,
        show_legend      = false,
        minimal          = false,

        keymaps          = {
          add_tag            = "<leader>ag",
          list_tags          = "<leader>la",
          toggle_extmarks    = "<F2>",
          trigger_keyed_tag  = "<leader>jf",
          trigger_keyed_file = "<leader>js",
          next_tag           = "<leader>ll",
          prev_tag           = "<leader>lh",
          symbol_tagging     = "ts",
          list_workspaces    = "<leader>ms",
        },

        workspace_window = {
          close               = "q",
          select              = "<CR>",
          toggle_ignore       = "d",
          rename              = "r",
          cycle_sort          = "s",
          toggle_show_ignored = "i",
          toggle_legend       = "l",
          toggle_minimal      = "m",
        },

        taglist_window   = {
          close          = "q",
          select         = "<CR>",
          delete         = "d",
          rename         = "r",
          clear          = "c",
          assign_key     = "a",
          clear_all_keys = "x",
          toggle_legend  = "l",
          toggle_minimal = "m",
        },
      })
    end)

    if not ok then
      vim.notify(
        "[tagonaut.nvim] setup failed: " .. err,
        vim.log.levels.ERROR,
        { title = "tagonaut.nvim" }
      )
    end
  end,
}
