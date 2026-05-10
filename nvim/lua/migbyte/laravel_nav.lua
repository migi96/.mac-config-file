-- lua/migbyte/laravel_nav.lua  -----------------------------------------------
-- Jump / fuzzy-find anywhere in a Laravel repo, even if the canonical
-- sub-folder (e.g. app/Http/Models) isn’t at the project root level.

local M = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Find the project root (artisan / composer.json / .git)
local function project_root()
  local markers = { "artisan", "composer.json", ".git" }
  local dir = vim.fn.expand("%:p:h")

  while dir ~= "/" do
    for _, m in ipairs(markers) do
      if vim.fn.filereadable(dir .. "/" .. m) == 1
          or vim.fn.isdirectory(dir .. "/" .. m) == 1
      then
        return dir
      end
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return vim.loop.cwd() -- fallback to CWD
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Resolve the *first* match of **/REL_PATH anywhere below root
local function resolve_path(root, rel)
  -- globpath returns a Vim list; convert to Lua list
  local matches = vim.fn.globpath(root, "**/" .. rel, 1, 1)
  if #matches > 0 then
    local p = matches[1]
    local is_dir = vim.fn.isdirectory(p) == 1
    return p, is_dir
  end
  return nil, false
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Public entry: open Telescope on the resolved dir (or the file directly)
function M.telescope_into(rel)
  local root           = project_root()
  local target, is_dir = resolve_path(root, rel)

  if not target then
    vim.notify("Laravel path not found: " .. rel, vim.log.levels.WARN)
    return
  end

  local builtin = require("telescope.builtin")

  if is_dir then
    builtin.find_files({ cwd = target, hidden = true, prompt_title = rel })
  else
    vim.cmd.edit(target)
  end
end

return M
