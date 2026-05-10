-- ============================================================================
-- AVANTE.NVIM - FIXED & AGENTIC CONFIGURATION
-- ============================================================================
-- Fixes applied:
-- 1. Fixed "VeryLlazy" typo -> "VeryLazy"
-- 2. Fixed E32 error by checking for valid filenames before reload
-- 3. Changed mode to "agentic" for full AI tool capabilities
-- 4. Simplified diff keybindings to use Avante's built-in mappings
-- 5. Removed problematic vim.cmd("e!") calls on unnamed buffers
-- ============================================================================

return {
  "yetone/avante.nvim",
  event = "VeryLazy", -- FIXED: was "VeryLlazy" (typo)
  lazy = false,
  version = false,    -- Never set this to "*"!
  build = "make",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "stevearc/dressing.nvim",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    {
      "rcarriga/nvim-notify",
      config = function()
        require("notify").setup({
          background_colour = "#000000",
          fps = 60,
          icons = {
            DEBUG = "",
            ERROR = "",
            INFO = "",
            TRACE = "✎",
            WARN = "",
          },
          level = 2,
          minimum_width = 50,
          render = "compact",
          stages = "fade_in_slide_out",
          timeout = 3000,
          top_down = true,
        })
        vim.notify = require("notify")
      end,
    },
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },

  -- ============================================================================
  -- KEYMAPS - Global Avante Actions
  -- ============================================================================
  keys = {
    -- Core shortcuts
    { "<leader>aa", function() require("avante.api").ask() end,      desc = "Avante: Ask AI",         mode = { "n", "v" } },
    { "<leader>ae", function() require("avante.api").edit() end,     desc = "Avante: Edit Selection", mode = "v" },
    { "<leader>ar", function() require("avante.api").refresh() end,  desc = "Avante: Refresh" },
    { "<leader>at", function() require("avante.api").toggle() end,   desc = "Avante: Toggle Sidebar" },
    { "<leader>af", function() require("avante.api").focus() end,    desc = "Avante: Focus Sidebar" },

    -- Chat management
    { "<leader>an", "<cmd>AvanteChatNew<cr>",                        desc = "Avante: New Chat" },
    { "<leader>ah", "<cmd>AvanteHistory<cr>",                        desc = "Avante: Chat History" },
    { "<leader>ac", "<cmd>AvanteClear<cr>",                          desc = "Avante: Clear Chat" },
    { "<leader>as", "<cmd>AvanteStop<cr>",                           desc = "Avante: Stop Request" },

    -- Settings
    { "<leader>al", "<cmd>AvanteModels<cr>",                         desc = "Avante: Switch Model" },
    { "<leader>ap", "<cmd>AvanteSwitchProvider<cr>",                 desc = "Avante: Switch Provider" },
    { "<leader>am", "<cmd>AvanteModels<cr>",                         desc = "Avante: Select Model" },
    { "<leader>ad", "<cmd>AvanteToggleDebug<cr>",                    desc = "Avante: Toggle Debug" },

    -- Advanced features
    { "<leader>az", function() require("avante.api").zen_mode() end, desc = "Avante: Zen Mode" },
    { "<leader>aR", "<cmd>AvanteShowRepoMap<cr>",                    desc = "Avante: Show Repo Map" },
  },

  -- ============================================================================
  -- MAIN CONFIGURATION
  -- ============================================================================
  opts = {
    -- ========================================
    -- Provider Settings
    -- ========================================
    provider = "copilot",

    -- ========================================
    -- MODE: AGENTIC (Full AI tool capabilities)
    -- ========================================
    -- "agentic" = AI can automatically execute tools (file ops, bash, web search)
    -- "legacy" = AI provides suggestions but requires manual approval
    mode = "agentic",

    -- Provider for auto-suggestions
    auto_suggestions_provider = "copilot",

    -- ========================================
    -- Provider Configurations
    -- ========================================
    providers = {
      copilot = {
        endpoint = "https://api.githubcopilot.com",
        model = "claude-sonnet-4", -- Copilot model ID (use :AvanteModels to see available)
        timeout = 120000,                   -- 2 minutes
        extra_request_body = {
          temperature = 0,
          max_tokens = 8192,
        },
      },
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-20250514",
        timeout = 120000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 20480,
        },
      },
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",
        timeout = 120000,
        extra_request_body = {
          temperature = 0.7,
          max_tokens = 4096,
        },
      },
    },

    -- ========================================
    -- Behavior Settings
    -- ========================================
    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true,
      enable_token_counting = true,
      auto_add_current_file = true,
      -- IMPORTANT: Set to true for agentic mode to auto-approve tools
      auto_approve_tool_permissions = true,
      confirmation_ui_style = "inline_buttons",
      acp_follow_agent_locations = true,
    },

    -- ========================================
    -- Keyboard Mappings (Avante Built-in)
    -- ========================================
    mappings = {
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      cancel = {
        normal = { "<C-c>", "<Esc>", "q" },
        insert = { "<C-c>" },
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        retry_user_request = "r",
        edit_user_request = "e",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
        remove_file = "d",
        add_file = "@",
        close = { "<Esc>", "q" },
        close_from_input = nil,
      },
    },

    -- ========================================
    -- Selection Hints
    -- ========================================
    selection = {
      enabled = true,
      hint_display = "delayed",
    },

    -- ========================================
    -- Window Configuration
    -- ========================================
    windows = {
      position = "right",
      wrap = true,
      width = 35,
      sidebar_header = {
        enabled = true,
        align = "center",
        rounded = true,
      },
      spinner = {
        editing = { "⡀", "⠄", "⠂", "⠁", "⠈", "⠐", "⠠", "⢀", "⣀", "⢄", "⢂", "⢁", "⢈", "⢐", "⢠", "⣠" },
        generating = { "·", "✢", "✳", "∗", "✻", "✽" },
        thinking = { "🤔", "💭" },
      },
      input = {
        prefix = "❯ ",
        height = 8,
      },
      edit = {
        border = "rounded",
        start_insert = true,
      },
      ask = {
        floating = false,
        start_insert = true,
        border = "rounded",
        focus_on_apply = "ours",
      },
    },

    -- ========================================
    -- Syntax Highlighting
    -- ========================================
    highlights = {
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },

    -- ========================================
    -- Diff Configuration
    -- ========================================
    diff = {
      autojump = true,
      list_opener = "copen",
      override_timeoutlen = 500,
    },

    -- ========================================
    -- Auto-suggestions Configuration
    -- ========================================
    suggestion = {
      debounce = 600,
      throttle = 600,
    },

    -- ========================================
    -- Hints Configuration
    -- ========================================
    hints = {
      enabled = true,
    },

    -- ========================================
    -- File Selector Provider
    -- ========================================
    selector = {
      provider = "telescope",
      provider_opts = {},
    },

    -- ========================================
    -- Input Provider
    -- ========================================
    input = {
      provider = "dressing",
      provider_opts = {
        title = "Avante Input",
        icon = " ",
      },
    },

    -- ========================================
    -- Project Instructions
    -- ========================================
    instructions_file = "avante.md",

    -- ========================================
    -- Custom Rules Directories
    -- ========================================
    rules = {
      project_dir = ".avante/rules",
      global_dir = vim.fn.expand("~/.config/avante/rules"),
    },

    -- ========================================
    -- Prompt Logger
    -- ========================================
    prompt_logger = {
      enabled = true,
      log_dir = vim.fn.stdpath("cache") .. "/avante_prompts",
      fortune_cookie_on_success = false,
      next_prompt = {
        normal = "<C-n>",
        insert = "<C-n>",
      },
      prev_prompt = {
        normal = "<C-p>",
        insert = "<C-p>",
      },
    },

    -- ========================================
    -- Dual Boost Mode (Experimental)
    -- ========================================
    dual_boost = {
      enabled = false,
      first_provider = "openai",
      second_provider = "claude",
      prompt =
      "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
      timeout = 60000,
    },

    -- ========================================
    -- Custom Shortcuts
    -- ========================================
    shortcuts = {
      {
        name = "refactor",
        description = "Refactor code with best practices",
        prompt =
        "Please refactor this code following best practices, improving readability and maintainability while preserving functionality.",
      },
      {
        name = "test",
        description = "Generate unit tests",
        prompt = "Please generate comprehensive unit tests for this code, covering edge cases and error scenarios.",
      },
      {
        name = "explain",
        description = "Explain code in detail",
        prompt =
        "Please explain this code in detail, including its purpose, how it works, and any important considerations.",
      },
      {
        name = "optimize",
        description = "Optimize code for performance",
        prompt = "Please optimize this code for better performance, focusing on efficiency and scalability.",
      },
      {
        name = "document",
        description = "Add documentation",
        prompt = "Please add comprehensive documentation to this code, including docstrings and inline comments.",
      },
    },

    -- ========================================
    -- Web Search Engine
    -- ========================================
    web_search_engine = {
      provider = "tavily",
      proxy = nil,
    },

    -- ========================================
    -- Custom Tools
    -- ========================================
    custom_tools = {},
  },

  -- ============================================================================
  -- POST-SETUP CONFIGURATION
  -- ============================================================================
  config = function(_, opts)
      -- Ensure required Avante signs exist to avoid E155 errors
      local function ensure_sign(name, text, texthl)
        local defined = vim.fn.sign_getdefined(name)
        if not defined or vim.tbl_isempty(defined) then
          vim.fn.sign_define(name, { text = text, texthl = texthl, numhl = "" })
        end
      end

      ensure_sign("AvanteInputPromptSign", "❯", "Identifier")
      ensure_sign("AvanteInputPromptSignActive", "➤", "Statement")

      -- Ensure Copilot is fully initialized before Avante provider setup
      do
        local lazy_ok, lazy = pcall(require, "lazy")
        if lazy_ok then
          pcall(lazy.load, { plugins = { "copilot.lua" }, wait = true })
        end
        pcall(function()
          require("copilot").setup({
            suggestion = { enabled = false },
            panel = { enabled = false },
          })
        end)
      end

      -- Check if Copilot auth token exists; if not, skip copilot provider
      local copilot_config = vim.fn.expand("~/.config/github-copilot")
      local has_hosts = vim.fn.filereadable(copilot_config .. "/hosts.json") == 1
      local has_apps = vim.fn.filereadable(copilot_config .. "/apps.json") == 1
      if not has_hosts and not has_apps then
        vim.notify(
          "⚠️  Copilot not authenticated! Run :Copilot auth first.\n   Falling back to 'openai' provider.",
          vim.log.levels.WARN,
          { title = "Avante" }
        )
        opts.provider = "openai"
      end

    require("avante").setup(opts)

    -- ========================================
    -- HELPER FUNCTIONS
    -- ========================================

    -- Notification helper with error handling
    local function notify(message, level)
      local ok, _ = pcall(function()
        vim.notify(message, level or vim.log.levels.INFO, {
          title = "Avante",
          icon = "🤖",
          timeout = 3000,
        })
      end)
      if not ok then
        -- Fallback to print if notify fails
        print("[Avante] " .. message)
      end
    end

    -- FIXED: Safe file reload that checks for valid filename first
    local function safe_reload_buffer(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()

      -- Check if buffer has a valid filename
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if filename == "" then
        -- Buffer has no filename, skip reload
        return false
      end

      -- Check if it's a special buffer type we shouldn't reload
      local buftype = vim.bo[bufnr].buftype
      if buftype ~= "" then
        -- Special buffer (like Avante buffers), skip reload
        return false
      end

      -- Check if file exists on disk
      if vim.fn.filereadable(filename) == 0 then
        return false
      end

      -- Safe to reload
      vim.schedule(function()
        pcall(function()
          vim.cmd("checktime")
        end)
      end)
      return true
    end

    -- ========================================
    -- GLOBAL TAB TOGGLE (CODE ↔ AVANTE)
    -- ========================================
    vim.keymap.set("n", "<Tab>", function()
      local current_buf = vim.api.nvim_get_current_buf()
      local ft = vim.bo[current_buf].filetype

      if ft == "Avante" or ft == "AvanteInput" or ft == "AvanteChat" then
        -- Switch back to code window
        vim.cmd("wincmd p")
        notify("⇆ Focus: Code", vim.log.levels.INFO)
      else
        -- Focus Avante sidebar
        local ok = pcall(function()
          require("avante.api").focus()
        end)
        if ok then
          notify("⇆ Focus: Avante", vim.log.levels.INFO)
        end
      end
    end, { desc = "Avante: Toggle Focus Code/Avante", silent = true })

    -- ========================================
    -- AUTOCMDS FOR PROPER BUFFER HANDLING
    -- ========================================

    -- Ensure Avante buffers are modifiable
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      pattern = "*",
      callback = function(args)
        local buftype = vim.bo[args.buf].buftype
        local filetype = vim.bo[args.buf].filetype

        if filetype == "Avante" or filetype == "AvanteInput" or filetype == "AvanteChat" or buftype == "acwrite" then
          vim.bo[args.buf].modifiable = true
        end
      end,
      desc = "Ensure Avante buffers are modifiable",
    })

    -- Handle Avante apply events with FIXED reload logic
    vim.api.nvim_create_autocmd("User", {
      pattern = "AvanteApply*",
      callback = function()
        notify("✅ Changes applied", vim.log.levels.INFO)

        -- FIXED: Use safe reload instead of vim.cmd("e!")
        vim.defer_fn(function()
          -- Find all windows and refresh their buffers if they have valid files
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            safe_reload_buffer(buf)
          end
        end, 100)
      end,
      desc = "Handle Avante apply events safely",
    })

    -- Handle diff operations
    vim.api.nvim_create_autocmd("User", {
      pattern = "AvanteDiff*",
      callback = function()
        vim.defer_fn(function()
          pcall(function()
            vim.cmd("checktime")
          end)
        end, 100)
      end,
      desc = "Refresh buffer after diff operations",
    })

    -- ========================================
    -- BUFFER-SPECIFIC KEYBINDINGS FOR AVANTE
    -- ========================================
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "Avante", "AvanteInput", "AvanteChat" },
      callback = function(args)
        local buf = args.buf

        -- Ensure buffer is modifiable
        vim.bo[buf].modifiable = true
        vim.bo[buf].readonly = false

        local opts_buf = { buffer = buf, silent = true, noremap = true }

        -- Add file to context
        vim.keymap.set("n", "@", function()
          local ok, avante = pcall(require, "avante")
          if ok then
            local sidebar = avante.get()
            if sidebar and sidebar.file_selector and sidebar.file_selector.open then
              sidebar.file_selector:open()
              notify("📁 Opening file selector", vim.log.levels.INFO)
            end
          end
        end, vim.tbl_extend("force", opts_buf, { desc = "Avante: Add file" }))

        -- Add file to context with %
        vim.keymap.set("n", "%", function()
          local ok, avante = pcall(require, "avante")
          if ok then
            local sidebar = avante.get()
            if sidebar and sidebar.file_selector and sidebar.file_selector.open then
              sidebar.file_selector:open()
              notify("📁 Opening file selector", vim.log.levels.INFO)
            end
          end
        end, vim.tbl_extend("force", opts_buf, { desc = "Avante: Add file (%)" }))
        -- Close sidebar
        vim.keymap.set("n", "q", function()
          local ok, avante = pcall(require, "avante")
          if ok then
            local sidebar = avante.get()
            if sidebar and sidebar.close then
              sidebar:close()
            end
          end
        end, vim.tbl_extend("force", opts_buf, { desc = "Avante: Close sidebar" }))
      end,
      desc = "Setup Avante buffer-specific keybindings",
    })

    -- ========================================
    -- GLOBAL LEADER KEYBINDINGS FOR DIFF
    -- ========================================
    -- These work from any buffer when there are active diffs

    vim.keymap.set("n", "<leader>aca", function()
      local ok, diff = pcall(require, "avante.diff")
      if ok and diff then
        pcall(function()
          diff.choose("all_theirs")
          notify("✅ Accepted ALL AI changes", vim.log.levels.INFO)
          vim.defer_fn(function()
            pcall(vim.cmd, "checktime")
          end, 100)
        end)
      end
    end, { desc = "Avante: Accept ALL AI changes", silent = true })

    vim.keymap.set("n", "<leader>act", function()
      local ok, diff = pcall(require, "avante.diff")
      if ok and diff then
        pcall(function()
          diff.choose("theirs")
          notify("✅ Accepted AI change", vim.log.levels.INFO)
          vim.defer_fn(function()
            pcall(vim.cmd, "checktime")
          end, 100)
        end)
      end
    end, { desc = "Avante: Accept AI change (theirs)", silent = true })

    vim.keymap.set("n", "<leader>aco", function()
      local ok, diff = pcall(require, "avante.diff")
      if ok and diff then
        pcall(function()
          diff.choose("ours")
          notify("✅ Kept current code", vim.log.levels.INFO)
        end)
      end
    end, { desc = "Avante: Keep current code (ours)", silent = true })

    -- ========================================
    -- ADD CURRENT FILE TO CONTEXT
    -- ========================================
    vim.keymap.set("n", "<leader>aC", function()
      local buf = vim.api.nvim_get_current_buf()
      local filepath = vim.api.nvim_buf_get_name(buf)
      if filepath ~= "" then
        local ok, avante = pcall(require, "avante")
        if ok then
          local sidebar = avante.get()
          if sidebar and sidebar.file_selector then
            local utils_ok, utils = pcall(require, "avante.utils")
            if utils_ok then
              local relative_path = utils.relative_path(filepath)
              sidebar.file_selector:add_selected_file(relative_path)
              notify("📄 Added: " .. relative_path, vim.log.levels.INFO)
            end
          end
        end
      end
    end, { desc = "Avante: Add Current File to context", silent = true })

    -- ========================================
    -- ADD ALL BUFFERS TO CONTEXT
    -- ========================================
    vim.keymap.set("n", "<leader>aB", function()
      local ok, avante = pcall(require, "avante")
      if ok then
        local sidebar = avante.get()
        if sidebar and sidebar.file_selector then
          local utils_ok, utils = pcall(require, "avante.utils")
          if utils_ok then
            local count = 0
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) then
                local filepath = vim.api.nvim_buf_get_name(buf)
                if filepath ~= "" and vim.fn.filereadable(filepath) == 1 then
                  local relative_path = utils.relative_path(filepath)
                  sidebar.file_selector:add_selected_file(relative_path)
                  count = count + 1
                end
              end
            end
            notify("📚 Added " .. count .. " buffers", vim.log.levels.INFO)
          end
        end
      end
    end, { desc = "Avante: Add All Buffers to context", silent = true })

    notify("✅ Avante loaded (Agentic Mode)", vim.log.levels.INFO)
  end,
}
