-- keymaps/flutter.lua
local map = vim.keymap.set

----------------------------------------------------------------
-- Helper: locate lib/ directory inside a Flutter project
----------------------------------------------------------------
local function find_lib_dir()
  local cwd = vim.fn.expand("%:p:h")
  local root_patterns = { ".git", "pubspec.yaml" }

  local function is_root(dir)
    for _, p in ipairs(root_patterns) do
      if vim.fn.glob(dir .. "/" .. p) ~= "" then
        return true
      end
    end
    return false
  end

  while cwd and cwd ~= "/" do
    if is_root(cwd) and vim.fn.isdirectory(cwd .. "/lib") == 1 then
      return cwd .. "/lib"
    end
    cwd = vim.fn.fnamemodify(cwd, ":h")
  end
  return nil
end
----------------------------------------------------------------
-- Mappings
----------------------------------------------------------------
-- <leader>mf : create folder inside lib/
map("n", "<leader>mf", function()
  local lib = find_lib_dir()
  if not lib then
    vim.notify("Could not find lib directory", vim.log.levels.ERROR)
    return
  end
  local folder = vim.fn.input("Folder name (in lib/): ")
  if folder ~= "" then
    local full = lib .. "/" .. folder
    vim.fn.mkdir(full, "p")
    vim.notify('Created folder: "' .. full .. '"', vim.log.levels.INFO)
  end
end, { desc = "Flutter: make folder in lib" })

-- <leader>mi : create (and open) file inside lib/
map("n", "<leader>mi", function()
  local lib = find_lib_dir()
  if not lib then
    vim.notify("Could not find lib directory", vim.log.levels.ERROR)
    return
  end
  local file = vim.fn.input("File path (relative to lib/): ")
  if file ~= "" then
    local full = lib .. "/" .. file
    local dir  = full:match("(.*[/\\])") or ""
    if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
    vim.cmd("edit " .. vim.fn.fnameescape(full))
    vim.notify('Created file: "' .. full .. '"', vim.log.levels.INFO)
  end
end, { desc = "Flutter: new file in lib" })
