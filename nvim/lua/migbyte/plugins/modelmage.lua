return {
  -- This is the most important part for a local plugin.
  -- The 'dir' key tells lazy.nvim to load the plugin directly from this folder
  -- instead of trying to download it from GitHub.
  --
  -- !!! IMPORTANT: You MUST change this path to where your modelmage.nvim folder is located.
  dir = "~/.config/nvim/lua/local/modelmage",

  -- Define keymaps to easily trigger the plugin.
  keys = {
    {
      "<leader>mm", -- Stands for [M]odel [M]age
      function()
        require("modelmage").generate_model()
      end,
      desc = "[M]odel [M]age: Generate new Freezed model",
    },
  },

  -- The setup function for the plugin.
  -- This is where you can pass your custom configuration to override the defaults.
  config = function()
    require("modelmage").setup({
      -- Example of overriding the default configuration:
      -- Set a custom import statement for your project's architecture.
      custom_import = "import '../../../features_exports.dart';",


      -- Decide if you want to run build_runner automatically after creation.
      auto_run_build_runner = true,
    })
  end,
}
