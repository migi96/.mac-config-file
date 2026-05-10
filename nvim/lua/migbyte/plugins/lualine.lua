return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")
    local icons = require("config.icons")

    local colors = {
      blue = "#65D1FF",
      green = "#3EFFDC",
      violet = "#FF61EF",
      yellow = "#FFDA7B",
      red = "#FF4A4A",
      fg = "#c3ccdc",
      bg = "#112638",
      inactive_bg = "#2c3043",
      semilightgray = "#6c7380",
    }

    local my_lualine_theme = {
      normal = {
        a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.green, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.red, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
        b = { bg = colors.inactive_bg, fg = colors.semilightgray },
        c = { bg = colors.inactive_bg, fg = colors.semilightgray },
      },
    }

    -- 1) Define minimal sections for "skitty" mode
    local skitty_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {
        {
          "diff",
          symbols = {
            added = icons.git.added,
            modified = icons.git.modified,
            removed = icons.git.removed,
          },
        },
      },
      lualine_y = {},
      lualine_z = {},
    }

    -- 2) Define full sections for "normal" mode
    local normal_sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_diagnostic" } } },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = {
        {
          function()
            -- Jira pipeline statusline: shows active ticket + elapsed time
            local ok, jira = pcall(require, "migbyte.plugins.jira")
            if ok and jira.statusline then
              return jira.statusline()
            end
            return ""
          end,
          cond = function()
            local ok, jira = pcall(require, "migbyte.plugins.jira")
            if ok and jira.statusline then
              return jira.statusline() ~= ""
            end
            return false
          end,
          color = { fg = "#f9e2af" },
        },
        {
          lazy_status.updates,
          cond = lazy_status.has_updates,
          color = { fg = colors.yellow },
        },
        { "encoding" },
        { "fileformat" },
        { "filetype" },
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    }

    -- 3) Pick which to use based on NEOVIM_MODE
    local final_sections = vim.g.neovim_mode == "skitty" and skitty_sections or normal_sections

    -- 4) Finally, set up lualine with a table
    lualine.setup({
      options = {
        theme = my_lualine_theme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        icons_enabled = true,
        globalstatus = true,
      },
      sections = final_sections,
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { "nvim-tree", "fugitive", "quickfix" },
    })
  end,
}
