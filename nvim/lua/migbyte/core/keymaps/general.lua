-- keymaps/general.lua
local map       = vim.keymap.set
vim.g.mapleader = " "

---------------------------------------------------------------
----------------------------------------------------------------
-- quick jumps / centering
----------------------------------------------------------------
map("n", "<C-x>", "zz", { desc = "Center screen (zz)", silent = true })
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down + center", silent = true })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up   + center", silent = true })

-- disable unused quickfix keys after plugins load
map("n", "<C-]>", "<nop>", { silent = true })
map("n", "<C-[>", "<nop>", { silent = true })

-- last buffer
map("n", "<C-b>", "<C-^>", { desc = "Last buffer" })
map("i", "<C-b>", "<Esc><C-^>", { desc = "Last buffer (insert)" })

-- exit insert + mark 'n'
map({ "i" }, "<Esc>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  vim.api.nvim_buf_set_mark(0, "n", vim.fn.line("."), vim.fn.col("."), {})
end, { desc = "Exit insert & set mark n" })

map({ "i" }, "jk", "<Esc><Cmd>mark n<CR>", { desc = "jk  → Esc + mark n", silent = true })

-- jump to mark
map("n", "<leader> ne ", "`n", { desc = "Jump to mark 'n'" })

-- jk in normal: leave insert, mark, save
map("n", "<leader>ne", function()
  vim.cmd([[execute "normal! \<Esc>"]])
  vim.cmd("mark n|write")
end, { desc = "Esc + mark n + save" })

-- visual-mode exit
map("v", "ne", "<Esc>", { desc = "Exit visual" })

-- quick quits
map("n", "<leader>ng", "<Esc>:wq<CR>", { desc = "Save & quit" })
map("n", "<leader>nn", "<Esc>:q!<CR>", { desc = "Quit w/o save" })

-- clear hlsearch
map("n", "<leader>nh", ":nohl<CR>", { desc = "No-highlight" })
-- exit insert mode and goes right
vim.keymap.set('i', 'hl', '<C-o>A', { desc = 'Exit insert mode, go to end of line, then re-enter insert' })

-- numbers
map("n", "<leader>+", "<C-a>", { desc = "Increment num" })
map("n", "<leader>-", "<C-x>", { desc = "Decrement num" })

-- whole-buffer yank
map("n", "<leader>lc", ":%y+<CR>", { desc = "Copy buffer" })

-- windows
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>sx", "<Cmd>close<CR>", { desc = "Close split" })

-- tabs
map("n", "<leader>to", "<Cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tx", "<Cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tn", "<Cmd>tabn<CR>", { desc = "Next tab" })
map("n", "<leader>te", "<Cmd>tabp<CR>", { desc = "Prev tab" })
map("n", "<leader>tf", "<Cmd>tabnew %<CR>", { desc = "Buf → new tab" })

----------------------------------------------------------------
-- JavaScript helpers
----------------------------------------------------------------
map("i", "<C-i>", "<Esc>f)a;<Esc>o", { desc = "Append ;" })
map("n", "<leader>dfk", "a(){}<Esc>F)i<CR>", { desc = "Insert (){}" })
map("n", "<leader>dfl", "a(){}<Esc>F}i<CR>", { desc = "Insert (){} params" })

map("n", "<leader>dj", "A{}<Esc>i<CR>", { desc = "Append {}" })
-- map("n", "<leader>rs", ":w<CR>:!node %<CR>", { desc = "Run Node" })

-- terminal split
map("n", "<leader>rt", ":vsplit term://zsh<CR>", { desc = "Zsh split" })

-- copy path
map("n", "<leader>cd", function()
  local path = vim.fn.expand("%:p:h")
  vim.fn.setreg("+", path)
  vim.notify('Copied: ' .. path)
end, { desc = "Copy dir" })


-- copy current file path
map("n", "<leader>yf", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify('Copied: ' .. path)
end, { desc = "Copy file path" })

-- telescope: keymaps finder
map("n", "<leader>yi", "<Cmd>Telescope keymaps<CR>", { desc = "Search keymaps (Telescope)" })

----------------------------------------------------------------
-- Copilot Management
----------------------------------------------------------------
map("n", "<leader>cu", "<Cmd>Copilot status<CR>", { desc = "Copilot status" })
map("n", "<leader>ca", "<Cmd>Copilot auth<CR>", { desc = "Copilot auth" })
map("n", "<leader>co", "<Cmd>Copilot signout<CR>", { desc = "Copilot signout" })
map("n", "<leader>cp", "<Cmd>Copilot panel<CR>", { desc = "Copilot panel" })

----------------------------------------------------------------
-- Vertical Split Management
----------------------------------------------------------------
-- Set right split to 80%
map("n", "<leader>sa", function()
  vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.8))
end, { desc = "Right split 80%" })

-- Set left split to 80%
map("n", "<leader>so", function()
  vim.cmd("wincmd h")
  vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.8))
end, { desc = "Left split 80%" })

-- Increase right split by 10%
map("n", "<leader>sk", function()
  local increase = math.floor(vim.o.columns * 0.1)
  vim.cmd("vertical resize +" .. increase)
end, { desc = "Right split +10%" })

-- Increase left split by 10%
map("n", "<leader>sj", function()
  local increase = math.floor(vim.o.columns * 0.1)
  vim.cmd("vertical resize -" .. increase)
end, { desc = "Left split +10%" })

-- Equal splits (50/50)
map("n", "<leader>su", "<C-w>=", { desc = "Equal splits" })

-- Quick toggle between 80% right and 80% left
map("n", "<leader>st", function()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  if #wins ~= 2 then
    vim.notify("Toggle only works with 2 vertical splits", vim.log.levels.WARN)
    return
  end

  local total_width = vim.o.columns
  local win1_width = vim.api.nvim_win_get_width(wins[1])
  local win2_width = vim.api.nvim_win_get_width(wins[2])

  -- Check which window is currently larger
  if win1_width > win2_width then
    -- Left is larger, make right larger
    vim.api.nvim_win_set_width(wins[1], math.floor(total_width * 0.2))
    vim.api.nvim_win_set_width(wins[2], math.floor(total_width * 0.8))
  else
    -- Right is larger (or equal), make left larger
    vim.api.nvim_win_set_width(wins[1], math.floor(total_width * 0.8))
    vim.api.nvim_win_set_width(wins[2], math.floor(total_width * 0.2))
  end
end, { desc = "Toggle split 80/20" })
