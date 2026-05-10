return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      width = 60,
      pane_gap = 4,
      sections = {
        -- 1) Terminal Section with the PNG image
        {
          section = "terminal",
          cmd = "ascii-image-converter " .. vim.fn.expand("~/.config/migbyte.png") .. " -C -c",
          random = 9999, -- or remove random/caching
          pane = 2,
          indent = 4,
          height = 25,
          align = "center", -- ensures the image is centered at the top
        },
        -- 2) Your custom MIGBYTE ASCII Header
        {
          section = "header",
          content = [[
 __  __ _____ ____  _
|  \/  |_   _| __ )| |
| |\/| | | | |  _ \| |
| |  | | | | | |_) | |___
|_|  |_| |_| |____/|_____|

        MIGBYTE
]],
          align = "center", -- Center-align the header text
        },
        -- 3) Keymaps Section
        {
          icon = " ",
          title = "Keymaps",
          section = "keys",
          indent = 2,
          padding = 1,
          items = {
            {
              text = {
                { "  ", hl = "SnacksDashboardIcon" },
                { "New File", hl = "SnacksDashboardDesc", width = 50 },
                { "[n]", hl = "SnacksDashboardKey" },
              },
              action = ":ene | startinsert",
              key = "n",
            },
            {
              text = {
                { "  ", hl = "SnacksDashboardIcon" },
                { "Find File", hl = "SnacksDashboardDesc", width = 50 },
                { "[f]", hl = "SnacksDashboardKey" },
              },
              action = ":Telescope find_files",
              key = "f",
            },
            {
              text = {
                { "  ", hl = "SnacksDashboardIcon" },
                { "Recent Files", hl = "SnacksDashboardDesc", width = 50 },
                { "[r]", hl = "SnacksDashboardKey" },
              },
              action = ":Telescope oldfiles",
              key = "r",
            },
            {
              text = {
                { "  ", hl = "SnacksDashboardIcon" },
                { "Config", hl = "SnacksDashboardDesc", width = 50 },
                { "[c]", hl = "SnacksDashboardKey" },
              },
              action = ":e $MYVIMRC",
              key = "c",
            },
            {
              text = {
                { "󰒲  ", hl = "SnacksDashboardIcon" },
                { "Lazy", hl = "SnacksDashboardDesc", width = 50 },
                { "[L]", hl = "SnacksDashboardKey" },
              },
              action = ":Lazy",
              key = "L",
            },
            {
              text = {
                { "  ", hl = "SnacksDashboardIcon" },
                { "Quit", hl = "SnacksDashboardDesc", width = 50 },
                { "[q]", hl = "SnacksDashboardKey" },
              },
              action = ":qa",
              key = "q",
            },
          },
        },
        -- 4) Recent Files Section
        {
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          indent = 2,
          padding = 1,
        },
        -- 5) Projects Section
        {
          icon = " ",
          title = "Projects",
          section = "projects",
          indent = 2,
          padding = 1,
        },
        -- 6) Startup Section
        { section = "startup" },
      },
    },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      },
    },
  },
  keys = {
    {
      "<leader>z",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
    },
    {
      "<leader>Z",
      function()
        Snacks.zen.zoom()
      end,
      desc = "Toggle Zoom",
    },
    {
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    {
      "<leader>no",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "<leader>cR",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File",
    },
    {
      "<leader>gbr",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git Browse",
      mode = { "n", "v" },
    },
    {
      "<leader>gbl",
      function()
        Snacks.git.blame_line()
      end,
      desc = "Git Blame Line",
    },
    {
      "<leader>gf",
      function()
        Snacks.lazygit.log_file()
      end,
      desc = "Lazygit Current File History",
    },
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>gl",
      function()
        Snacks.lazygit.log()
      end,
      desc = "Lazygit Log (cwd)",
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
    {
      "<c-/>",
      function()
        Snacks.terminal()
      end,
      desc = "Toggle Terminal",
    },
    {
      "]]",
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = "Next Reference",
      mode = { "n", "t" },
    },
    {
      "[[",
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = "Prev Reference",
      mode = { "n", "t" },
    },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle
            .option("background", { off = "light", on = "dark", name = "Dark Background" })
            :map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
