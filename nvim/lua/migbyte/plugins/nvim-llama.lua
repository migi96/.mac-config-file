return {
  {
    'jpmcb/nvim-llama',
    lazy = true,
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'Llama' },
    config = function()
      require('nvim-llama').setup({
        debug = false,
        -- Use llama.cpp server instead of Ollama
        server = {
          host = 'http://localhost',
          port = '8080',              -- Default port for first model
          endpoints = {
            generate = '/completion', -- llama.cpp endpoint
          }
        },
        -- Model configurations
        models = {
          {
            name = 'deepseek-7b',
            server = { port = 8080 }, -- Matches your llama.cpp 7B instance
            parameters = {
              temperature = 0.7,
              max_tokens = 512
            }
          },
          {
            name = 'deepseek-13b',
            server = { port = 8081 }, -- Matches your llama.cpp 13B instance
            parameters = {
              temperature = 0.5,
              max_tokens = 1024
            }
          }
        }
      })

      -- Keybindings for model selection
      vim.api.nvim_set_keymap('n', '<leader>d7', [[:Llama -m deepseek-7b<CR>]], { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>d13', [[:Llama -m deepseek-13b<CR>]], { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ds', [[:LlamaChat<CR>]], { noremap = true, silent = true })
    end,
  },
}
