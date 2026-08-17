-- Colored scrollback viewer for herdr's prefix+e (edit-scrollback.sh).
-- Renders the captured ANSI file in a :terminal buffer so the terminal colors
-- show, then behaves like a read-only pager with vim keys (gg = very top,
-- / = search, q / Esc = quit and return to the source tab).
-- Env: HERDR_SB_FILE (the .ans capture), HERDR_SB_RETURN_TAB (tab to refocus).
-- Launched with `nvim -u NONE` for instant startup; the terminal buffer renders
-- ANSI regardless of colorscheme (termguicolors gives 24-bit).
vim.opt.termguicolors = true
vim.opt.scrollback = 100000   -- keep the whole capture scrollable (nvim max)
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = 'no'
vim.opt.laststatus = 0
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.mouse = 'a'

local HERDR = '/opt/homebrew/bin/herdr'
local f = vim.env.HERDR_SB_FILE or ''
local ret = vim.env.HERDR_SB_RETURN_TAB or ''

local function quit()
  if ret ~= '' then
    pcall(vim.fn.system, { HERDR, 'tab', 'focus', ret })  -- back to the source tab first
  end
  vim.cmd('qa!')                                          -- closing this pane closes the viewer tab
end

if f == '' or vim.fn.filereadable(f) == 0 then
  quit()
  return
end

-- Register BEFORE :terminal so we never race `cat` exiting.
vim.api.nvim_create_autocmd('TermClose', {
  once = true,
  callback = function()
    vim.schedule(function()
      -- leave terminal-insert -> normal mode, jump to the very top
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes('<C-\\><C-n>gg', true, false, true), 'n', false)
      local o = { buffer = vim.api.nvim_get_current_buf(), nowait = true, silent = true }
      vim.keymap.set('n', 'q', quit, o)
      vim.keymap.set('n', '<Esc>', quit, o)
    end)
  end,
})

vim.cmd('terminal cat -- ' .. vim.fn.fnameescape(f))
