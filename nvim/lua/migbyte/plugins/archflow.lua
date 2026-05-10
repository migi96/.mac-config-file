-- -- ~/.config/nvim/lua/migbyte/plugins/archflow.lua

return {
  -- This path now correctly points to your local plugin folder
  dir = "~/.config/nvim/lua/local/archflow-nvim",

  -- The keymap configuration
  keys = {
    {
      "<leader>af",
      function()
        require("archflow").generate_feature()
      end,
      desc = "[A]rch[F]low: Generate new feature",
    },
  },

  -- The setup configuration for the plugin
  config = function()
    require("archflow").setup()
  end,
}
