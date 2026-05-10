return {
	"turbio/bracey.vim",
	run = "npm install --prefix server",
	config = function()
		-- Set up keymaps for Bracey
		local keymap = vim.keymap -- for conciseness

		-- Start live preview
		keymap.set("n", "<leader>bl", "<cmd>Bracey<CR>", { desc = "Start live HTML preview" })

		-- Stop live preview
		keymap.set("n", "<leader>bs", "<cmd>BraceyStop<CR>", { desc = "Stop live HTML preview" })

		-- Reload live preview
		keymap.set("n", "<leader>br", "<cmd>BraceyReload<CR>", { desc = "Reload live HTML preview" })

		-- Note: Make sure you have Node.js and npm installed for Bracey to work.
	end,
}
