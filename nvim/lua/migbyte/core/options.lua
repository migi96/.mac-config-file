vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

-- Conditional settings based on mode
if vim.g.neovim_mode == "skitty" then
  -- Line numbers
  opt.number = false
  opt.relativenumber = false
  -- Text width and wrapping
  opt.textwidth = 28
  local colors = require("config.colors")
  vim.cmd(string.format([[highlight WinBar1 guifg=%s]], colors["linkarzu_color03"]))
  opt.winbar = "%#WinBar1# %t%*%=%#WinBar1# linkarzu %*"
  -- Cursor settings for skitty mode
  opt.guicursor = {
    "n-v-c-sm:block-Cursor",
    "i-ci-ve:ver25-lCursor",
    "r-cr:hor20-CursorIM",
  }
else
  -- Regular Neovim settings
  opt.relativenumber = true
  opt.number = true
  -- Regular cursor settings
  opt.guicursor = {
    "n-v-c-sm:block",
    "i-ci-ve:ver25",
    "r-cr:hor20",
  }
end

-- Common settings for both modes
opt.statuscolumn = "%s %l %r"
vim.o.statuscolumn = "%s %l %r "
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")
opt.splitright = true
opt.splitbelow = true
opt.swapfile = false
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- ============================================================================
-- Avante.nvim Required Settings
-- ============================================================================

-- Global statusline (REQUIRED for Avante to render properly)
opt.laststatus = 3

-- Fix for E21 error - make Avante buffers modifiable
vim.api.nvim_create_autocmd("FileType", {
  pattern = "Avante",
  callback = function()
    vim.bo.modifiable = true
    vim.bo.buftype = "acwrite"
  end,
  desc = "Make Avante buffers modifiable",
})

-- Fix for Avante input window
vim.api.nvim_create_autocmd("FileType", {
  pattern = "AvanteInput",
  callback = function()
    vim.bo.modifiable = true
  end,
  desc = "Make Avante input modifiable",
})

-- Optional: Better visual experience for Avante
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "Avante", "AvanteInput" },
  callback = function()
    -- Disable line numbers in Avante windows for cleaner look
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
  end,
  desc = "Clean UI for Avante windows",
})
