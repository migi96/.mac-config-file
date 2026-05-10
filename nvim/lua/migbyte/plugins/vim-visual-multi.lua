-- ~/.config/nvim/lua/plugins/visual-multi.lua
return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = { "bufreadpre", "bufnewfile" },
  config = function()
    -- make sure you have set your mapleader somewhere before this!
    -- vim.g.mapleader = " "

    vim.g.vm_maps = {
      -- normal / visual: add cursor at next match
      ["find under"]         = "<leader>el",
      -- same for subwords
      ["find subword under"] = "<leader>ej",
      -- (you can remap any other vm command here)
    }
  end,
}
