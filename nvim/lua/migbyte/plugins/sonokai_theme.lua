return {
  {
    "sainnhe/sonokai",
    lazy = false,    -- Ensure the plugin loads immediately
    priority = 1000, -- Load this plugin with high priority
    config = function()
      -- Configure and load the Sonokai colorscheme
      vim.g.sonokai_enable_italic = 1          -- Enable italic text
      vim.g.sonokai_transparent_background = 0 -- Disable transparent background (optional)
      vim.g.sonokai_style =
      "default"                                -- Set default Sonokai style (changeable to 'atlantis', 'andromeda', 'shusia', 'maia', 'espresso')
      vim.cmd.colorscheme("sonokai")           -- Apply the Sonokai colorscheme
    end,
  },
}
