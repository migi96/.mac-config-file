return {
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    lazy = false,
    config = function()
      -- FZF key mappings
      vim.keymap.set("n", "<C-p>", ":Files<CR>", { silent = true, desc = "Find files" })
      vim.keymap.set("n", "<Leader>rg", ":Rg<CR>", { silent = true, desc = "Search with Rg" })
      vim.keymap.set("n", "<Leader>fb", ":Buffers<CR>", { silent = true, desc = "Find buffers" })
      vim.keymap.set("n", "<Leader>ho", ":History<CR>", { silent = true, desc = "Search history" })


      -- Preview window settings
      vim.cmd [[
        let g:fzf_preview_window = ['right:50%', 'ctrl-/']
      ]]
    end,
  },
}
