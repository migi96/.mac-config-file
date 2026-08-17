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
    -- nvim-notify is noice's notification backend.
    {
      "rcarriga/nvim-notify",
      opts = {
        -- Fixes the startup warning: "Highlight group 'NotifyBackground' has no
        -- background highlight". nvim-notify needs a concrete colour for its
        -- transparency fallback; without it, it warns and defaults to #000000.
        -- (avante used to call notify.setup with this; avante is now disabled.)
        background_colour = "#000000",
      },
      config = function(_, opts)
        require("notify").setup(opts)
      end,
    },
  },
}
