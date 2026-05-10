return {
  "nanozuki/tabby.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- For file icons
  config = function()
    -- Custom theme for Tabby
    local theme = {
      fill = { fg = "#a89984", bg = "#282828" },                        -- Background of the tabline
      head = { fg = "#ebdbb2", bg = "#389d6a", style = "bold" },        -- Left section
      current_tab = { fg = "#1d2021", bg = "#fabd2f", style = "bold" }, -- Active tab
      tab = { fg = "#ebdbb2", bg = "#3c3836" },                         -- Inactive tab
      win = { fg = "#ebdbb2", bg = "#504945" },                         -- Window highlight
      tail = { fg = "#ebdbb2", bg = "#d79921", style = "bold" },        -- Right section
    }

    require("tabby").setup({
      line = function(line)
        return {
          {
            { "  ", hl = theme.head },
            line.sep("", theme.head, theme.fill),
          },
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            return {
              line.sep("", hl, theme.fill),
              tab.is_current() and "" or "󰆣",
              tab.number(),
              tab.name(),
              tab.close_btn(""),
              line.sep("", hl, theme.fill),
              hl = hl,
              margin = " ",
            }
          end),
          line.spacer(),
          line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
            return {
              line.sep("", theme.win, theme.fill),
              win.is_current() and "" or "",
              win.buf_name(),
              line.sep("", theme.win, theme.fill),
              hl = theme.win,
              margin = " ",
            }
          end),
          {
            line.sep("", theme.tail, theme.fill),
            { "  ", hl = theme.tail },
          },
          hl = theme.fill,
        }
      end,
      option = {
        theme = {
          fill = theme.fill,
          head = theme.head,
          current_tab = theme.current_tab,
          tab = theme.tab,
          win = theme.win,
          tail = theme.tail,
        },
        tab_name = {
          name_fallback = function(tabid)
            return "Tab " .. tabid
          end,
        },
        buf_name = {
          mode = "relative", -- Show relative paths for buffer names
        },
        nerdfont = true,     -- Enable nerdfont icons
        lualine_theme = nil, -- No lualine theme integration
      },
    })

    -- Key mappings for tab management
    vim.api.nvim_set_keymap("n", "<leader>ta", ":$tabnew<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tc", ":tabclose<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>to", ":tabonly<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tn", ":tabn<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tp", ":tabp<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tmp", ":-tabmove<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tmn", ":+tabmove<CR>", { noremap = true, silent = true })
  end,
}
