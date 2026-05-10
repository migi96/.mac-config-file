return {
	"norcalli/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	config = function()
		require("colorizer").setup({
			"*", -- Highlight all files, or customize file types like "css", "javascript"
			css = { rgb_fn = true }, -- Enable `rgb()` and `rgba()` functions in CSS
			html = { names = true }, -- Enable color names like "red", "blue", etc.
		})
	end,
}
