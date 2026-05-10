return {
	{
		"akinsho/toggleterm.nvim",
		version = "*", -- Use the latest stable version
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<c-\>]], -- Toggle terminal with Ctrl-\
				insert_mappings = true, -- Apply mappings in insert mode
				terminal_mappings = true, -- Apply mappings in terminal mode
				persist_size = true, -- Retain terminal size between sessions
				direction = "horizontal", -- Default direction for general toggling
				float_opts = {
					border = "curved", -- Border style for floating terminal
					winblend = 3, -- Transparency for the floating terminal
				},
				start_in_insert = true, -- Start terminal in insert mode
				shade_terminals = true, -- Shade terminal background
				shading_factor = 2, -- Level of shading applied to terminal
				close_on_exit = true, -- Close terminal window when process exits
			})

			-- Define floating terminal
			local Terminal = require("toggleterm.terminal").Terminal
			local float_term = Terminal:new({ direction = "float" })

			-- Define two horizontal terminals
			local horiz_term1 = Terminal:new({ direction = "horizontal", size = 15 })
			local horiz_term2 = Terminal:new({ direction = "horizontal", size = 15 })

			-- Define two vertical terminals
			local vert_term1 = Terminal:new({ direction = "vertical", size = 50 })
			local vert_term2 = Terminal:new({ direction = "vertical", size = 50 })

			-- Key mapping for floating terminal
			vim.keymap.set("n", "<leader>tl", function()
				float_term:toggle()
			end, { desc = "Toggle Floating Terminal" })

			-- Key mapping for double horizontal terminals
			vim.keymap.set("n", "<leader>tdh", function()
				horiz_term1:toggle()
				horiz_term2:toggle()
			end, { desc = "Toggle Double Horizontal Terminals" })

			-- Key mapping for double vertical terminals
			vim.keymap.set("n", "<leader>tdv", function()
				vert_term1:toggle()
				vert_term2:toggle()
			end, { desc = "Toggle Double Vertical Terminals" })

			-- Key mappings for terminal window navigation
			function _G.set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			end

			vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
		end,
	},
}
