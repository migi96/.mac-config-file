return {
  "vinnymeller/swagger-preview.nvim",

  -- This command triggers the plugin to load
  cmd = { "SwaggerPreview", "SwaggerPreviewStop", "SwaggerPreviewToggle" },

  -- Automatically runs `npm i` to install the swagger-ui-watcher dependency
  build = "npm i",

  -- This function runs after the plugin is loaded
  config = function()
    -- Optional: Customize the port or host
    require("swagger-preview").setup({
      port = 8000,
      host = "localhost",
    })

    -- ✅ Add your shortcuts (keymaps) here
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Toggle the preview with <leader>sp (for Swagger Preview)
    keymap("n", "<leader>sp", "<cmd>SwaggerPreviewToggle<CR>", {
      desc = "[S]wagger [P]review Toggle",
      unpack(opts),
    })

    -- Stop the preview with <leader>sS (for Swagger Stop)
    keymap("n", "<leader>sS", "<cmd>SwaggerPreviewStop<CR>", {
      desc = "[S]wagger [S]top",
      unpack(opts),
    })
  end,
}
