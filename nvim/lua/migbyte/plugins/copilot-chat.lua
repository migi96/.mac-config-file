-- File: lua/plugins/copilot-chat.lua

return {
  "CopilotC-Nvim/CopilotChat.nvim",

  -- REMOVED: The incorrect `branch = "master"` line has been deleted.
  -- lazy.nvim will now automatically use the correct default branch ('main').

  dependencies = {
    { "nvim-lua/plenary.nvim" }, -- No need to specify branch here either
  },

  -- The build step is recommended to install `tiktoken` for accurate token counting
  build = "make tiktoken",

  -- Main configuration for the plugin
  opts = {
    -- Default model to use. You can use any model available through your GitHub Copilot account.
    -- Common options: 'gpt-4o', 'gpt-4', 'gpt-3.5-turbo'.
    -- The availability of Claude models depends on your GitHub Copilot settings.
    model = "gpt-4o",

    -- Lower temperature for more focused, deterministic answers.
    temperature = 0.1,

    -- Configuration for the chat window appearance and layout.
    window = {
      layout = "float", -- Use a floating window for the chat.
      width = 0.6,      -- Use 60% of the screen width.
      height = 0.8,     -- Use 80% of the screen height.
      border = "rounded",
      title = "🤖 Copilot Chat",
      zindex = 100,
    },

    -- Automatically enter insert mode when the chat window opens.
    auto_insert_mode = true,

    -- Custom prompts. You can define your own or override built-in ones.
    -- Use these by typing `/` in the chat, e.g., `/ClaudeSonnet`.
    prompts = {
      -- This prompt allows you to force the use of Claude 3.5 Sonnet
      ClaudeSonnet = {
        model = "claude-3.5-sonnet-20240620",
        prompt = "Using the Claude 3.5 Sonnet model, please answer the following:",
        system_prompt = "You are a helpful coding assistant powered by Claude 3.5 Sonnet.",
        description = "Chat with Claude 3.5 Sonnet",
      },
      -- Example of a fun custom prompt
      Pirate = {
        system_prompt = "You are a pirate. Please answer all questions in a pirate dialect.",
        description = "Chat with a pirate.",
      },
      -- You can add more prompts here
    },

    -- Custom headers for chat messages.
    headers = {
      user = "👤 You",
      assistant = "🤖 Copilot",
      tool = "🔧 Tool",
    },
  },

  -- All keymaps will start with <leader>cc followed by another letter (excluding 'o').
  keys = {
    -- Toggle the main chat window
    { "<leader>cct", function() require("CopilotChat").toggle() end,        desc = "Toggle Chat" },

    -- Reset the current chat session
    { "<leader>ccr", function() require("CopilotChat").reset() end,         desc = "Reset Chat" },

    -- Stop the current AI response
    { "<leader>ccs", function() require("CopilotChat").stop() end,          desc = "Stop Response" },

    -- Open the prompt selection menu
    { "<leader>ccp", function() require("CopilotChat").select_prompt() end, desc = "Select Prompt" },

    -- Open the model selection menu
    { "<leader>ccm", function() require("CopilotChat").select_model() end,  desc = "Select Model" },

    -- Quick actions on visually selected code
    { "<leader>cce", "<cmd>CopilotChat Explain<cr>",                        mode = "v",                      desc = "Explain Code" },
    { "<leader>ccw", "<cmd>CopilotChat Review<cr>",                         mode = "v",                      desc = "Review Code" },
    { "<leader>ccf", "<cmd>CopilotChat Fix<cr>",                            mode = "v",                      desc = "Fix Code" },
    { "<leader>ccz", "<cmd>CopilotChat Optimize<cr>",                       mode = "v",                      desc = "Optimize Code" },
    { "<leader>ccd", "<cmd>CopilotChat Docs<cr>",                           mode = "v",                      desc = "Generate Docs" },
    { "<leader>ccx", "<cmd>CopilotChat Tests<cr>",                          mode = "v",                      desc = "Generate Tests" },

    -- Generate a commit message based on staged git changes
    { "<leader>ccc", "<cmd>CopilotChat Commit<cr>",                         desc = "Generate Commit Message" },
  },
}
