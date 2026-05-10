-- lua/migbyte/plugins/todo_float.lua
return {
  {
    "migbyte/todo-float",
    -- point at your local module instead of a remote repo
    dir = vim.fn.stdpath("config") .. "/lua/migbyte/cool_stuff",
    config = function()
      -- load & configure your todo_float module
      require("migbyte.cool_stuff").setup({
        target_file = "todo.md",
        global_file = "~/notes/todo.md",
      })

      -- one‐keystroke edit of this plugin spec
      vim.keymap.set("n", "<leader>tdl", function()
        local path = vim.fn.stdpath("config") .. "/lua/migbyte/plugins/todo_float.lua"
        vim.cmd("edit " .. path)
      end, {
        noremap = true,
        silent = true,
        desc = "Edit todo-float plugin spec",
      })
    end,
  },
}
