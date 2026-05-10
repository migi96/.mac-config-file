return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next,     -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    -- Search files in current working directory
    keymap.set("n", "<leader>it", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>ir", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>is", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>iu", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>if", "<cmd>Telescope lsp_workspace_symbols<cr>", { desc = "Find function in project" })
    keymap.set("n", "<leader>id", "<cmd>Telescope lsp_document_symbols<cr>",
      { desc = "Find symbols in current document" })
    -- ADDED THIS LINE
    keymap.set("n", "<leader>in", function()
      require("telescope.builtin").live_grep({
        prompt_title = "Find Future Functions in File",
        default_text = "Future<",               -- Pre-fill search for async functions
        search_dirs = { vim.fn.expand("%:p") }, -- Search only the current file
      })
    end, { desc = "Find async (Future) functions in file" })
    keymap.set("n", "<leader>io", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

    -- Search Neovim configuration files
    keymap.set("n", "<leader>fg", function()
      require("telescope.builtin").find_files({
        prompt_title = "Neovim Config",
        cwd = vim.fn.stdpath("config"), -- Set cwd to Neovim config path
      })
    end, { desc = "Search Neovim config files" })

    -- Search all vaults
    keymap.set("n", "<leader>fv", function()
      require("telescope.builtin").find_files({
        prompt_title = "Obsidian Vaults",
        cwd = "/Users/migbyte/me_myself_i/", -- Root directory of all vaults
      })
    end, { desc = "Search all vaults" })

    -- Search all notes across all vaults
    keymap.set("n", "<leader>fn", function()
      require("telescope.builtin").live_grep({
        prompt_title = "Search All Notes",
        cwd = "/Users/migbyte/me_myself_i/", -- Root directory of all vaults
      })
    end, { desc = "Search all notes across vaults" })
  end,
}
