return {
  -- AI integration with the opencode assistant
  "NickvanDyke/opencode.nvim",
  -- The UI for this plugin (prompts, pickers) is powered by snacks.nvim
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {} } },
  },
  config = function()
    -- ┌──────────────────────────────────────────────────────────┐
    -- │                       CONFIGURATION                      │
    -- └──────────────────────────────────────────────────────────┘
    -- All available options and their defaults can be found in the plugin's
    -- source code at `lua/opencode/config.lua`.
    -- The defaults are very sensible, so you may not need to change anything.
    vim.g.opencode_opts = {
      -- Example: If you wanted to define custom prompts, you would add them here.
      -- prompts = {
      --   my_prompt = {
      --     prompt = "Translate @this to Spanish",
      --     desc = "Translate the selection to Spanish",
      --   },
      -- },
    }

    -- This global setting is required for the `auto_reload` feature, which
    -- automatically reloads buffers when the opencode AI edits them.
    vim.opt.autoread = true

    -- ┌──────────────────────────────────────────────────────────┐
    -- │                        KEYBINDINGS                       │
    -- └──────────────────────────────────────────────────────────┘
    -- These keymaps provide quick access to all core features of the plugin.
    -- The `<leader>o` prefix stands for "opencode".
    local opencode = require("opencode")

    -- Core Actions
    vim.keymap.set({ "n", "x" }, "<leader>oa", function() opencode.ask("@this: ", { submit = true }) end,
      { desc = "[O]pencode [A]sk about this" })
    vim.keymap.set({ "n", "x" }, "<leader>os", function() opencode.select() end, { desc = "[O]pencode [S]elect prompt" })
    vim.keymap.set({ "n", "x" }, "<leader>o+", function() opencode.prompt("@this") end,
      { desc = "[O]pencode Add this to prompt" })
    vim.keymap.set({ "n", "x" }, "<leader>oe", function()
      -- Custom keymap for a favorite prompt, as recommended in the docs.
      local explain = require("opencode.config").opts.prompts.explain
      opencode.prompt(explain.prompt, explain)
    end, { desc = "[O]pencode [E]xplain this" })


    -- Embedded Terminal & Commands
    vim.keymap.set("n", "<leader>ot", function() opencode.toggle() end, { desc = "[O]pencode [T]oggle embedded" })
    vim.keymap.set("n", "<leader>oc", function() opencode.command() end, { desc = "[O]pencode Select [C]ommand" })

    -- Session Management
    vim.keymap.set("n", "<leader>on", function() opencode.command("session_new") end,
      { desc = "[O]pencode [N]ew session" })
    vim.keymap.set("n", "<leader>oi", function() opencode.command("session_interrupt") end,
      { desc = "[O]pencode [I]nterrupt session" })
    vim.keymap.set("n", "<leader>oA", function() opencode.command("agent_cycle") end,
      { desc = "[O]pencode Cycle selected [A]gent" })

    -- Message/UI Navigation (useful when the opencode panel is visible)
    vim.keymap.set("n", "<S-C-u>", function() opencode.command("messages_half_page_up") end,
      { desc = "Messages half page up" })
    vim.keymap.set("n", "<S-C-d>", function() opencode.command("messages_half_page_down") end,
      { desc = "Messages half page down" })

    print("opencode.nvim loaded with custom config and keymaps.")
  end,
}
