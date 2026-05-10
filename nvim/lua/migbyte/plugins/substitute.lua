return {
	"gbprod/substitute.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local substitute = require("substitute")

		substitute.setup()

		-- set keymaps with a unique prefix to avoid conflicts
		local keymap = vim.keymap

		-- Substitute with motion
		keymap.set("n", "<leader>sm", substitute.operator, { desc = "Substitute with motion" })

		-- Substitute the current line
		keymap.set("n", "<leader>sl", substitute.line, { desc = "Substitute line" })

		-- Substitute to the end of line
		keymap.set("n", "<leader>se", substitute.eol, { desc = "Substitute to end of line" })

		-- Substitute in visual mode
		keymap.set("x", "<leader>sv", substitute.visual, { desc = "Substitute in visual mode" })
	end,
}
