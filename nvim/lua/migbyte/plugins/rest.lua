return {
  "rest-nvim/rest.nvim",
  ft = { "http" },
  cmd = { "Rest" },
  dependencies = {
    -- This clever function ensures the "http" parser is installed
    -- without you having to add it to your treesitter config manually.
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        if type(opts.ensure_installed) == "table" then
          vim.list_extend(opts.ensure_installed, { "http" })
        end
      end,
    },
    "nvim-telescope/telescope.nvim",
  },
  -- Keymaps MUST be set after the plugin is loaded
  config = function()
    local map = vim.keymap.set
    map("n", "<leader>mr", ":Rest last<CR>", { desc = "Run last HTTP request" })
    map("n", "<leader>mR", ":Rest run<CR>", { desc = "Run HTTP request under cursor" })
    map("n", "<leader>mo", ":Rest open<CR>", { desc = "Open Rest.nvim result pane" })
    map("n", "<leader>mc", ":Rest cookies<CR>", { desc = "Edit Rest.nvim cookies file" })
    map("n", "<leader>me", ":Rest env show<CR>", { desc = "Show environment file used by Rest.nvim" })

    -- Telescope integration
    pcall(require("telescope").load_extension, "rest")
    map("n", "<leader>rs", ":Telescope rest select_env<CR>", { desc = "Select Rest.nvim environment file" })
  end,
}
