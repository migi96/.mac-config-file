return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring", -- for JSX, TSX, etc.
  },
  config = function()
    -- Import Comment.nvim safely
    local comment = require("Comment")

    -- Import ts-context-commentstring integration
    local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

    -- Setup Comment.nvim
    comment.setup({
      mappings = {
        -- Enable keybindings for normal and visual mode
        basic = true, -- `gcc` for normal mode, `gc` for visual mode
        extra = true, -- Enables `gb` for block comments
      },
      -- Hook for file-specific comment strings (e.g., TSX, JSX)
      pre_hook = ts_context_commentstring.create_pre_hook(),
    })

    -- OPTIONAL: Add keybinding to uncomment in visual mode
    -- Select lines in visual mode and press `gc` to toggle comments
    vim.api.nvim_set_keymap("v", "gc", "<Plug>(comment_toggle_linewise_visual)", { noremap = false, silent = true })
  end,
}
