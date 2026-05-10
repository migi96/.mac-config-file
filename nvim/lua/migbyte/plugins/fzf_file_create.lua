-- lua/plugins/fzf_file_create.lua
local fzf = require("fzf-lua")

-- Basic file creation in current buffer’s directory
local function create_file()
  local cwd = vim.fn.expand("%:p:h")
  vim.ui.input({ prompt = "New file name: " }, function(name)
    if not (name and #name > 0) then return end
    local path = cwd .. "/" .. name
    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end)
end

-- Basic directory creation in current buffer’s directory
local function create_dir()
  local cwd = vim.fn.expand("%:p:h")
  vim.ui.input({ prompt = "New dir name: " }, function(name)
    if not (name and #name > 0) then return end
    local path = cwd .. "/" .. name
    vim.fn.mkdir(path, "p")
    vim.notify("Created directory: " .. path, vim.log.levels.INFO)
  end)
end

-- Smart create helper:
--  - path = "layouts/create.blade.php"
--  - is_file = true|false
local function smart_create(path, is_file)
  local buf_dir = vim.fn.expand("%:p:h")
  local root    = vim.fn.getcwd()     -- your project root
  local p       = path:gsub("^/", "") -- strip leading '/'
  if p == "" then return end

  -- split into base + rest
  local parts   = vim.split(p, "/", true)
  local base    = parts[1]
  local rest    = table.concat(parts, "/", 2)

  -- find existing directories named `base` under project root
  local matches = vim.fn.globpath(root, "**/" .. base, false, true)
  local target
  for _, m in ipairs(matches) do
    if vim.fn.isdirectory(m) == 1 then
      target = m
      break
    end
  end

  if not target then
    -- fallback: create base folder under current buffer dir
    target = buf_dir .. "/" .. base
    vim.fn.mkdir(target, "p")
  end

  -- build final path
  local final = rest ~= "" and (target .. "/" .. rest) or target

  if is_file then
    vim.fn.mkdir(vim.fn.fnamemodify(final, ":h"), "p")
    vim.cmd("edit " .. vim.fn.fnameescape(final))
  else
    vim.fn.mkdir(final, "p")
    vim.notify("Created directory: " .. final, vim.log.levels.INFO)
  end
end

-- smart file creation (leader cf)
local function create_file_smart()
  vim.ui.input({ prompt = "Smart file path (e.g. /layouts/create.blade.php): " }, function(input)
    if not (input and #input > 0) then return end
    smart_create(input, true)
  end)
end

-- smart dir creation (leader cj)
local function create_dir_smart()
  vim.ui.input({ prompt = "Smart dir path (e.g. /layouts/subdir): " }, function(input)
    if not (input and #input > 0) then return end
    smart_create(input, false)
  end)
end

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {
        "<leader>bd",
        function()
          fzf.files({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = " FZF: browse files",
      },
      {
        "<leader>cF",
        create_file,
        desc = " Create new file in cwd",
      },
      {
        "<leader>cf",
        create_file_smart,
        desc = " Smart create file in existing dir",
      },
      {
        "<leader>cJ",
        create_dir,
        desc = " Create new dir in cwd",
      },
      {
        "<leader>cj",
        create_dir_smart,
        desc = " Smart create dir in existing dir",
      },
    },
  },
}
