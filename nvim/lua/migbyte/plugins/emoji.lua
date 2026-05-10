return {
	"allaman/emoji.nvim",
	version = "1.0.0", -- Pin to a specific version
	ft = { "markdown", "text" }, -- Adjust filetypes as needed
	dependencies = {
		-- Required for telescope integration
		"nvim-lua/plenary.nvim",
		-- Optional for nvim-cmp integration
		"hrsh7th/nvim-cmp",
		-- Optional for telescope integration
		"nvim-telescope/telescope.nvim",
		-- Optional for fzf-lua integration
		"ibhagwan/fzf-lua",
	},
	opts = {
		enable_cmp_integration = true, -- Enable nvim-cmp integration
		plugin_path = vim.fn.stdpath("data") .. "/lazy/", -- Default path for lazy.nvim
	},
	config = function(_, opts)
		-- Load and configure emoji.nvim
		require("emoji").setup(opts)

		-- Optional: Telescope integration
		if pcall(require, "telescope") then
			require("telescope").load_extension("emoji")
		end

		-- Key mappings for emoji.nvim functionality
		local keymap = vim.keymap

		-- Keybinding for emoji selection using Telescope
		keymap.set("n", "<leader>em", function()
			if pcall(require, "telescope") then
				require("telescope").extensions.emoji.emoji()
			else
				vim.notify("Telescope is not installed or configured", vim.log.levels.ERROR)
			end
		end, { desc = "Search and Insert Emoji" })

		-- Optional message to confirm plugin setup
		vim.notify("emoji.nvim fully configured", vim.log.levels.INFO)
	end,
}
