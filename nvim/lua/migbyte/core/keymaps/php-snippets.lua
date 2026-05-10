-- lua/migbyte/core/keymaps/php-snippets.lua
-- Common PHP snippet expansions with Ctrl‑d jump helper

local map = vim.keymap.set

----------------------------------------------------------------
-- Ctrl‑d helper (Insert mode): jump inside next '[' or '{'
----------------------------------------------------------------
map("i", "<C-d>", "<Esc>/[\\[{]<CR>li", {
  noremap = true,
  silent  = true,
  desc    = "Jump inside [] or {}"
})

----------------------------------------------------------------
-- Snippets ----------------------------------------------------
----------------------------------------------------------------

-- Public function snippet: "public function () {}"
-- After typing the name, press Ctrl‑d to jump inside { }
map("i", "mpt", "<Esc>ipublic function () {}<Esc>F(hi", {
  noremap = true,
  silent = true,
  desc = "PHP: public function snippet",
})

-- Array assignment snippet: "$ = [];"
-- After typing the variable name, press Ctrl‑d to jump inside [ ]
map("i", "mpa", "<Esc>i$ = [];<Esc>F$ha", {
  noremap = true,
  silent = true,
  desc = "PHP: array assignment snippet",
})

-- Public property snippet
map("i", "mpp", "<Esc>ipublic $ ;<Esc>F$ha", {
  noremap = true,
  silent = true,
  desc = "PHP: public property snippet",
})

-- Private property snippet
map("i", "mpv", "<Esc>iprivate $ ;<Esc>F$ha", {
  noremap = true,
  silent = true,
  desc = "PHP: private property snippet",
})

-- Public const snippet
map("i", "mpc", "<Esc>ipublic const  = ;<Esc>F=hi", {
  noremap = true,
  silent = true,
  desc = "PHP: public const snippet",
})

-- Return snippet
map("i", "mpr", "<Esc>ireturn ;<Esc>F;hi", {
  noremap = true,
  silent = true,
  desc = "PHP: return snippet",
})

-- Namespace snippet
map("i", "mnk", "<Esc>inamespace ;<Esc>F;hi", {
  noremap = true,
  silent = true,
  desc = "PHP: namespace snippet",
})

-- Use/import snippet
map("i", "mus", "<Esc>iuse ;<Esc>F;hi", {
  noremap = true,
  silent = true,
  desc = "PHP: use snippet",
})

-- If statement snippet
map("i", "mif", "<Esc>iif () {}<Esc>F)hi", {
  noremap = true,
  silent = true,
  desc = "PHP: if statement snippet",
})

-- Foreach loop snippet
map("i", "mfg", "<Esc>iforeach () {}<Esc>F)hi", {
  noremap = true,
  silent = true,
  desc = "PHP: foreach snippet",
})

-- Class skeleton snippet
map("i", "mcl", "<Esc>iclass  {}<Esc>F{hi", {
  noremap = true,
  silent = true,
  desc = "PHP: class snippet",
})
