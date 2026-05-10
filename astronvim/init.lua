-- Debugging: Print initialization start
print("Initializing AstroNvim configuration...")

-- Define the Lazy.nvim path
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Forcefully add Lazy.nvim to the runtime path
local lazypath = "/Users/migbyte/.local/share/astronvim/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- Debugging: Print the runtime path
print("Runtime path updated:")
print(vim.inspect(vim.opt.rtp:get()))


-- Debugging: Print the Lazy.nvim path
print("Lazy.nvim path: " .. lazypath)

-- Clone Lazy.nvim if not already installed
if not vim.loop.fs_stat(lazypath) then
  print("Lazy.nvim not found. Cloning repository...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- Latest stable release
    lazypath,
  })
  print("Lazy.nvim cloned successfully.")
else
  print("Lazy.nvim already installed.")
end

-- Prepend Lazy.nvim to the runtime path
vim.opt.rtp:prepend(lazypath)

-- Debugging: Print runtime path after adding Lazy.nvim
print("Runtime path after prepending Lazy.nvim:")
print(vim.inspect(vim.opt.rtp:get()))

-- Validate that Lazy.nvim is available
if not pcall(require, "lazy") then
  print("Error: Unable to load Lazy.nvim!")
  vim.api.nvim_echo(
    { { ("Unable to load Lazy.nvim from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } },
    true, {}
  )
  vim.fn.getchar()
  vim.cmd.quit()
else
  print("Lazy.nvim loaded successfully.")
end

-- Load Lazy.nvim setup and custom modules
print("Setting up Lazy.nvim with lazy_setup module...")
local success, err = pcall(require, "lazy")
if not success then
  print("Error loading lazy: " .. err)
else
  require("lazy").setup("lazy_setup") -- Ensure this module exists
  print("Lazy.nvim setup completed.")
end

-- Debugging: Load the 'polish' module
print("Loading 'polish' module...")
local polish_success, polish_err = pcall(require, "polish")
if not polish_success then
  print("Error loading polish: " .. polish_err)
else
  print("'polish' module loaded successfully.")
end

print("AstroNvim configuration initialization complete.")
