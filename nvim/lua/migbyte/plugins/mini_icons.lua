-- mini_icons.lua

return {
	"echasnovski/mini.nvim",
	config = function()
		-- Initialize mini.icons
		require("mini.icons").setup({
			-- You can add custom icons here, for example:
			icons = {
				Error = "✘",
				Warning = "⚠",
				Info = "ℹ️",
				Hint = "💡",
			},
		})
	end,
}
