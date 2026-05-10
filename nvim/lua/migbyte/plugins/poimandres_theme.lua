return {
  {
    'olivercederborg/poimandres.nvim',
    lazy = false,    -- Load immediately
    priority = 1000, -- Load early
    config = function()
      -- Set up Poimandres with custom configuration
      require('poimandres').setup {
        bold_vert_split = true,           -- Use bold vertical separators
        dim_nc_background = true,         -- Dim 'non-current' window backgrounds
        disable_background = false,       -- Keep the background enabled
        disable_float_background = false, -- Enable float backgrounds
        disable_italics = false,          -- Allow italics
      }
    end,

    -- Set the colorscheme within lazy.nvim configuration
    init = function()
      -- Apply the colorscheme after the setup
      vim.cmd("colorscheme poimandres")
    end,
  },
}
