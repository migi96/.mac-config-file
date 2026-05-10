return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- Add any options here, e.g.,
    -- lsp = { override = { ["vim.lsp.util.convert_input_to_markdown_lines"] = true } }
  },
  dependencies = {
    -- Ensure proper lazy-loading by adding `module="..."` if needed for dependencies
    "MunifTanjim/nui.nvim",
    -- Optional: Include nvim-notify if you want enhanced notification features
    "rcarriga/nvim-notify",
  },
}
