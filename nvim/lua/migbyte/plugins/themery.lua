return {
  {
    "zaldih/themery.nvim",
    lazy = false, -- Ensure the plugin loads immediately
    config = function()
      require("themery").setup({

        themes       = {

          -- Nordfox Theme
          {
            name        = "Nordfox",
            colorscheme = "nordfox",
            before      = [[
              vim.g.nord_contrast = true
              vim.g.nord_borders = false
              vim.g.nord_disable_background = false
              vim.g.nord_italic = false
              vim.g.nord_uniform_diff_background = true
              vim.g.nord_bold = false
            ]],
          },

          -- Terafox Theme
          {
            name        = "Terafox",
            colorscheme = "terafox",
            before      = [[
              require("nightfox").setup({
                options = {
                  transparent = true,
                  terminal_colors = true,
                  styles = {
                    comments = "italic",
                    keywords = "bold",
                    functions = "italic,bold",
                  },
                },
              })
            ]],
          },

          -- Ashen Theme
          {
            name        = "Ashen",
            colorscheme = "ashen",
            before      = [[
    -- Enable termguicolors for proper color rendering
    vim.opt.termguicolors = true

    -- Configure Ashen.nvim with custom options
    require("ashen").setup({
      style = {
        bold = true,           -- Enable bold text
        italic = true,         -- Enable italic text
        underline = true,      -- Enable underlined text
      },
      style_presets = {
        bold_functions = true,     -- Bold for functions
        italic_comments = true,    -- Italicize comments
      },
      palette_override = {
        bg = "#2B2B2B",        -- Background color override
        fg = "#F0F0F0",        -- Foreground color override
        accent = "#D08770",    -- Accent color
        hint = "#88C0D0",      -- Hint text color
        error = "#BF616A",     -- Error color
      },
      terminal_palette = {
        black = "#3B4048",
        red = "#BF616A",
        green = "#A3BE8C",
        yellow = "#EBCB8B",
        blue = "#81A1C1",
        magenta = "#B48EAD",
        cyan = "#88C0D0",
        white = "#ECEFF4",
      },
      plugin_integration = {
        telescope = true,      -- Integrate with Telescope
        lualine = true,        -- Enable Lualine support
        cmp = true,            -- Enable nvim-cmp support
        trailblazer = true,    -- Enable trailblazer.nvim integration
        oil = true,            -- Enable oil.nvim support
      },
      highlight_override = {
        Comment = { fg = "#88C0D0", italic = true }, -- Comments in cyan with italic
        Function = { fg = "#D08770", bold = true },  -- Functions in orange with bold
        String = { fg = "#A3BE8C", italic = true },  -- Strings in green with italic
        Variable = { fg = "#EBCB8B" },              -- Variables in yellow
        Conditional = { fg = "#D08770", bold = true }, -- Conditionals in orange with bold
        Visual = { bg = "#434C5E" },                -- Visual selection background
        PmenuSel = { bg = "#5E81AC", fg = "#ECEFF4", bold = true }, -- Popup menu selection
        CursorLine = { bg = "#3B4252" },            -- Highlight for the current line
      },
    })

    -- Apply the Ashen.nvim theme
    vim.cmd("colorscheme ashen")
  ]],
          },

          -- Catppuccin Latte Theme
          {
            name        = "Catppuccin Latte",
            colorscheme = "catppuccin",
            before      = [[
              require("catppuccin").setup({
                flavour = "latte",
                transparent_background = true,
                show_end_of_buffer = true,
                term_colors = true,
                no_italic = false,
                no_bold = false,
                custom_highlights = function(colors)
                  return {
                    Comment = { fg = colors.surface2, italic = true },
                    Function = { fg = colors.blue, bold = true },
                    Keyword = { fg = colors.pink, bold = true },
                    String = { fg = colors.green, italic = true },
                    Variable = { fg = colors.yellow },
                  }
                end,
              })
              vim.cmd("colorscheme catppuccin")
            ]],
          },

          -- Catppuccin Frappe Theme
          {
            name        = "Catppuccin Frappe",
            colorscheme = "catppuccin",
            before      = [[
              require("catppuccin").setup({
                flavour = "frappe",
                transparent_background = false,
                show_end_of_buffer = true,
                term_colors = true,
                no_italic = false,
                no_bold = false,
                custom_highlights = function(colors)
                  return {
                    Comment = { fg = colors.surface2, italic = true },
                    Function = { fg = colors.blue, bold = true },
                    Keyword = { fg = colors.pink, bold = true },
                    String = { fg = colors.green, italic = true },
                    Variable = { fg = colors.yellow },
                  }
                end,
              })
              vim.cmd("colorscheme catppuccin")
            ]],
          },

          -- Catppuccin Macchiato Theme
          {
            name        = "Catppuccin Macchiato",
            colorscheme = "catppuccin",
            before      = [[
              require("catppuccin").setup({
                flavour = "macchiato",
                transparent_background = true,
                show_end_of_buffer = true,
                term_colors = true,
                no_italic = false,
                no_bold = false,
                custom_highlights = function(colors)
                  return {
                    Comment = { fg = colors.surface2, italic = true },
                    Function = { fg = colors.blue, bold = true },
                    Keyword = { fg = colors.pink, bold = true },
                    String = { fg = colors.green, italic = true },
                    Variable = { fg = colors.yellow },
                  }
                end,
              })
              vim.cmd("colorscheme catppuccin")
            ]],
          },

          -- Catppuccin Mocha Theme
          {
            name        = "Catppuccin Mocha",
            colorscheme = "catppuccin",
            before      = [[
              require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = true,
                show_end_of_buffer = true,
                term_colors = true,
                no_italic = false,
                no_bold = false,
                custom_highlights = function(colors)
                  return {
                    Comment = { fg = colors.surface2, italic = true },
                    Function = { fg = colors.blue, bold = true },
                    Keyword = { fg = colors.pink, bold = true },
                    String = { fg = colors.green, italic = true },
                    Variable = { fg = colors.yellow },
                  }
                end,
              })
              vim.cmd("colorscheme catppuccin")
            ]],
          },

          -- Minimal Theme
          {
            name        = "Minimal",
            colorscheme = "minimal",
            before      = [[
    -- Enable termguicolors for proper color rendering
    vim.opt.termguicolors = true

    -- Minimal.nvim configurations
    vim.g.minimal_italic_comments = true       -- Enable italic comments
    vim.g.minimal_italic_keywords = true       -- Enable italic keywords
    vim.g.minimal_italic_booleans = true       -- Enable italic booleans
    vim.g.minimal_italic_functions = true      -- Enable italic functions
    vim.g.minimal_italic_variables = false     -- Disable italic variables
    vim.g.minimal_transparent_background = true -- Keep the background opaque

    -- Custom highlights for Minimal.nvim
    vim.api.nvim_create_autocmd("ColorScheme", {
      group   = vim.api.nvim_create_augroup("custom_highlights_minimal", {}),
      pattern = "minimal",
      callback = function()
        local set_hl = vim.api.nvim_set_hl
        set_hl(0, "Comment", { fg = "#6C7680", italic = true }) -- Italicized comments in gray
        set_hl(0, "Keyword", { fg = "#D08770", bold = true })  -- Bold keywords in orange
        set_hl(0, "Function", { fg = "#8FBCBB", italic = true }) -- Italicized functions in teal
        set_hl(0, "String", { fg = "#A3BE8C", bold = true })   -- Bold strings in green
        set_hl(0, "Variable", { fg = "#EBCB8B" })               -- Variables in yellow
        set_hl(0, "PmenuSel", { bg = "#4C566A", fg = "#ECEFF4", bold = true }) -- Popup menu selection
        set_hl(0, "Visual", { bg = "#434C5E" })                 -- Visual selection background
        set_hl(0, "CursorLine", { bg = "#3B4252" })             -- Highlight current line
      end,
    })

    -- Apply the Minimal.nvim theme
    vim.cmd("colorscheme minimal")
  ]],
          },

          -- Kurayami Theme
          {
            name        = "Kurayami",
            colorscheme = "kurayami",
            before      = [[
    -- Enable termguicolors for proper color rendering
    if vim.fn.has("termguicolors") == 1 then
      vim.opt.termguicolors = true
    end

    -- Configure Kurayami theme with custom highlights
    require("kurayami").setup({
      override = {
        Comment         = { fg = "#7C7C7C", italic = true },  -- Subtle comments
        Keyword         = { fg = "#D87F57", bold   = true },  -- Keywords in dark orange
        Function        = { fg = "#FFB86C", bold   = true },  -- Functions in bright orange
        String          = { fg = "#99C794", italic = true },  -- Strings in green
        Number          = { fg = "#FFD700", bg     = "NONE", bold = true }, -- Numbers in gold
        Boolean         = { fg = "#FF6E6E", bold   = true },  -- Booleans in red
        Variable        = { fg = "#76C6FF" },                -- Variables in light blue
        Conditional     = { fg = "#EBCB8B", bold = true },    -- Conditionals in aurora yellow
        Visual          = { bg = "#4C566A" },                 -- Visual selection background
        CursorLine      = { bg = "#3B4252" },                 -- Highlight current line
        PmenuSel        = { bg = "#5E81AC", fg = "#ECEFF4", bold = true }, -- Popup selection
        TelescopeBorder = { fg = "#4C566A" },                 -- Telescope border
        TelescopePrompt = { bg = "#3B4252", fg = "#D8DEE9" }, -- Telescope prompt
        TelescopeResults= { bg = "#2E3440", fg = "#ECEFF4" }, -- Telescope results
      },
    })

    -- Apply the Kurayami theme
    vim.cmd("colorscheme kurayami")
  ]],
          },

          -- Darkvoid Theme
          {
            name        = "Darkvoid",
            colorscheme = "darkvoid",
            before      = [[
    -- Enable termguicolors for proper color rendering
    if vim.fn.has("termguicolors") == 1 then
      vim.opt.termguicolors = true
    end

    -- Configure Darkvoid theme with custom settings
    require("darkvoid").setup({
      monochromatic = true,
      glow_effect   = true,
      transparency  = true,
      plugins = {
        nvim_tree    = true,
        treesitter   = true,
        telescope    = true,
        gitsigns     = true,
        bufferline   = true,
        lualine      = true,
        oil          = true,
        whichkey     = true,
        nvim_cmp     = true,
        nvim_notify  = true,
      },
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group   = vim.api.nvim_create_augroup("custom_highlights_darkvoid", {}),
      pattern = "darkvoid",
      callback = function()
        local set_hl = vim.api.nvim_set_hl
        set_hl(0, "Comment", { fg = "#7C7C7C", italic = true })
        set_hl(0, "Keyword", { fg = "#FF6E6E", bold = true })
        set_hl(0, "Function", { fg = "#FFD700", bold = true })
        set_hl(0, "String", { fg = "#A3D977", italic = true })
        set_hl(0, "Variable", { fg = "#76C6FF" })
        set_hl(0, "Visual",   { bg = "#303030" })
        set_hl(0, "CursorLine", { bg = "#252525" })
        set_hl(0, "PmenuSel",  { bg = "#FFD700", fg = "#1E1E1E", bold = true })
      end,
    })

    -- Apply the Darkvoid theme
    vim.cmd("colorscheme darkvoid")
  ]],
          },

          -- Boo Colorscheme: Forest Stream
          {
            name        = "Boo Colorscheme - Forest Stream",
            colorscheme = "boo",
            before      = [[
    if vim.fn.has("termguicolors") == 1 then
      vim.opt.termguicolors = true
    end
    require("boo-colorscheme").use({
      italic = true,
      theme  = "forest_stream",
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group   = vim.api.nvim_create_augroup("custom_highlights_boo_forest_stream", {}),
      pattern = "boo",
      callback = function()
        local set_hl = vim.api.nvim_set_hl
        set_hl(0, "Comment", { fg = "#7A8C8B", italic = true })
        set_hl(0, "Keyword", { fg = "#8EC07C", bold   = true })
        set_hl(0, "Function", { fg = "#D79921", italic = true })
        set_hl(0, "String",   { fg = "#B8BB26" })
        set_hl(0, "Variable", { fg = "#FABD2F" })
        set_hl(0, "Visual",   { bg = "#3C3836" })
        set_hl(0, "CursorLine", { bg = "#282828" })
        set_hl(0, "PmenuSel",   { bg = "#458588", fg = "#EBDBB2", bold = true })
      end,
    })
    vim.cmd("colorscheme boo")
  ]],
          },

          -- Boo Colorscheme: Sunset Cloud
          {
            name        = "Boo Colorscheme - Sunset Cloud",
            colorscheme = "boo",
            before      = [[
    if vim.fn.has("termguicolors") == 1 then
      vim.opt.termguicolors = true
    end
    require("boo-colorscheme").use({
      italic = true,
      theme  = "sunset_cloud",
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group   = vim.api.nvim_create_augroup("custom_highlights_boo_sunset_cloud", {}),
      pattern = "boo",
      callback = function()
        local set_hl = vim.api.nvim_set_hl
        set_hl(0, "Comment", { fg = "#A89984", italic = true })
        set_hl(0, "Keyword", { fg = "#D3869B", bold   = true })
        set_hl(0, "Function", { fg = "#E5C07B", italic = true })
        set_hl(0, "String",   { fg = "#83A598" })
        set_hl(0, "Variable", { fg = "#FABD2F" })
        set_hl(0, "Visual",   { bg = "#504945" })
        set_hl(0, "CursorLine", { bg = "#3C3836" })
        set_hl(0, "PmenuSel",   { bg = "#D65D0E", fg = "#EBDBB2", bold = true })
      end,
    })
    vim.cmd("colorscheme boo")
  ]],
          },

          -- Oceanic Next Theme
          {
            name        = "Oceanic Next",
            colorscheme = "OceanicNext",
            before      = [[
    vim.opt.termguicolors = true
    vim.g.oceanic_next_terminal_bold   = 1
    vim.g.oceanic_next_terminal_italic = 1
    vim.api.nvim_create_autocmd("ColorScheme", {
      group   = vim.api.nvim_create_augroup("custom_highlights_oceanic_next", {}),
      pattern = "OceanicNext",
      callback = function()
        local set_hl = vim.api.nvim_set_hl
        set_hl(0, "Comment", { fg = "#65737E", italic = true })
        set_hl(0, "Keyword", { fg = "#C594C5", bold   = true })
        set_hl(0, "Function", { fg = "#6699CC", italic = true })
        set_hl(0, "String",   { fg = "#99C794" })
        set_hl(0, "Visual",   { bg = "#4F5B66" })
        set_hl(0, "CursorLine", { bg = "#343D46" })
        set_hl(0, "PmenuSel",   { bg = "#6699CC", fg = "#FFFFFF" })
      end,
    })
    vim.cmd("colorscheme OceanicNext")
  ]],
          },

          -- Gruvbox Baby Theme
          {
            name        = "Gruvbox Baby",
            colorscheme = "gruvbox-baby",
            before      = [[
    vim.g.gruvbox_baby_function_style  = "NONE"
    vim.g.gruvbox_baby_keyword_style   = "italic"
    vim.g.gruvbox_baby_comment_style   = "italic"
    vim.g.gruvbox_baby_string_style    = "nocombine"
    vim.g.gruvbox_baby_variable_style  = "NONE"
    vim.g.gruvbox_baby_highlights = {
      Normal = { fg = "#ebdbb2", bg = "NONE", style = "NONE" },
      Comment = { fg = "#928374", bg = "NONE", style = "italic" },
      Keyword = { fg = "#d79921", bg = "NONE", style = "italic" },
      String  = { fg = "#b8bb26", bg = "NONE", style = "NONE" },
      Function= { fg = "#fabd2f", bg = "NONE", style = "NONE" },
    }
    vim.g.gruvbox_baby_transparent_mode   = 1
    vim.g.gruvbox_baby_telescope_theme    = 1
    vim.cmd("colorscheme gruvbox-baby")
  ]],
          },

          -- Poimandres Theme
          {
            name        = "Poimandres",
            colorscheme = "poimandres",
            before      = [[
    require("poimandres").setup({
      bold_vert_split      = true,
      dim_nc_background    = true,
      disable_background   = false,
      disable_float_background = false,
      disable_italics      = false,
    })
    vim.cmd("colorscheme poimandres")
  ]],
          },

          -- Melange Theme
          {
            name        = "Melange",
            colorscheme = "melange",
            before      = [[
    vim.opt.termguicolors = true
    vim.api.nvim_create_autocmd("ColorScheme", {
      group   = vim.api.nvim_create_augroup("custom_highlights_melange", {}),
      pattern = "melange",
      callback = function()
        local set_hl = vim.api.nvim_set_hl
        set_hl(0, "Comment", { fg = "#6C6C6C", italic = true })
        set_hl(0, "Keyword", { fg = "#D08770", bold   = true })
        set_hl(0, "Function",{ fg = "#8FBCBB", italic = true })
        set_hl(0, "String",  { fg = "#A3BE8C", bold   = true })
        set_hl(0, "Variable",{ fg = "#EBCB8B" })
        set_hl(0, "PmenuSel", { bg = "#5E81AC", fg = "#ECEFF4", bold = true })
        set_hl(0, "Visual",   { bg = "#434C5E" })
        set_hl(0, "CursorLine",{ bg = "#3B4252" })
      end,
    })
    vim.cmd("colorscheme melange")
  ]],
          },

          -- Bamboo Theme
          {
            name        = "Bamboo",
            colorscheme = "bamboo",
            before      = [[
    require("bamboo").setup({
      style      = "vulgaris",
      transparent= true,
      dim_inactive = true,
      term_colors = true,
      ending_tildes = true,
      cmp_itemkind_reverse = false,
      code_style = {
        comments     = { italic = true },
        conditionals = { italic = true },
        keywords     = { bold   = true },
        functions    = { italic = true },
        namespaces   = { italic = true },
      },
      lualine     = { transparent = false },
      diagnostics = {
        darker      = true,
        undercurl   = true,
        background  = true,
      },
      colors      = {
        bright_orange = "#ff8800",
        green         = "#00ffaa",
      },
      highlights  = {
        ["@comment"]         = { fg = "$grey" },
        ["@keyword"]         = { fg = "$green", bold = true },
        ["@string"]          = { fg = "$bright_orange", bg = "#303030", bold = true },
        ["@function"]        = { fg = "#00aaff", italic = true, underline = true },
        ["@function.builtin"]= { fg = "#0059ff" },
      },
    })
    require("bamboo").load()
  ]],
          },

          -- Nordern.nvim Theme
          {
            name        = "Nordern",
            colorscheme = "nordern",
            before      = [[
    if vim.fn.has("termguicolors") == 1 then
      vim.opt.termguicolors = true
    end
    require("nordern").setup({
      brighter_comments    = true,
      brighter_conditionals= true,
      italic_comments      = true,
      transparent          = true,
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group   = vim.api.nvim_create_augroup("custom_highlights_nordern", {}),
      pattern = "nordern",
      callback = function()
        local set_hl = vim.api.nvim_set_hl
        set_hl(0, "Comment",    { fg = "#88C0D0", italic = true })
        set_hl(0, "Keyword",    { fg = "#EBCB8B", bold   = true })
        set_hl(0, "Function",   { fg = "#81A1C1", bold   = true })
        set_hl(0, "String",     { fg = "#A3BE8C" })
        set_hl(0, "Variable",   { fg = "#D8DEE9" })
        set_hl(0, "Conditional",{ fg = "#EBCB8B", bold   = true })
        set_hl(0, "Visual",     { bg = "#4C566A" })
        set_hl(0, "CursorLine", { bg = "#3B4252" })
        set_hl(0, "PmenuSel",   { bg = "#5E81AC", fg = "#ECEFF4", bold = true})
        set_hl(0, "TelescopeBorder", { fg = "#4C566A" })
        set_hl(0, "TelescopePrompt", { bg = "#3B4252", fg = "#D8DEE9" })
        set_hl(0, "TelescopeResults",{ bg = "#2E3440", fg = "#ECEFF4" })
      end,
    })
    vim.cmd("colorscheme nordern")
  ]],
          },

          -- CitrusZest Theme
          {
            name        = "CitrusZest",
            colorscheme = "citruszest",
            before      = [[
    require("citruszest").setup({
      option = {
        transparent = true,
        bold        = true,
        italic      = true,
      },
      style = {
        Comment    = { fg = "#00CC7A", italic = true },
        Constant   = { fg = "#FFD700", bold   = true },
        Identifier = { fg = "#00BFFF", bold   = true },
        Function   = { fg = "#FF7431", italic = true },
        Statement  = { fg = "#FF1A75", bold   = true },
        Visual     = { bg = "#404040" },
        CursorLine = { bg = "#383838" },
        PmenuSel   = { bg = "#FFD700" },
      },
    })
    vim.cmd("colorscheme citruszest")
  ]],
          },

          -- Edge Theme
          {
            name        = "Edge",
            colorscheme = "edge",
            before      = [[
    vim.g.edge_style                   = "aura"
    vim.g.edge_better_performance      = 1
    vim.g.edge_enable_italic           = true
    vim.g.edge_disable_italic_comment  = false
    vim.g.edge_dim_foreground          = 1
    vim.g.edge_cursor                  = "auto"
    vim.g.edge_transparent_background  = 0
    vim.g.edge_dim_inactive_windows    = 1
    vim.g.edge_menu_selection_background = "blue"
    vim.g.edge_spell_foreground        = "colored"
    vim.g.edge_show_eob                = 0
    vim.g.edge_float_style             = "dim"
    vim.g.edge_diagnostic_text_highlight  = 1
    vim.g.edge_diagnostic_virtual_text    = "highlighted"
    vim.g.edge_current_word           = "underline"
    vim.g.edge_inlay_hints_background = "dimmed"
    vim.g.edge_disable_terminal_colors = 0
    vim.g.edge_colors_override = {
      bg0 = { "#1e222a", "233" },
      bg2 = { "#2c313c", "234" },
      red = { "#ff6c6b", "167" },
    }
    vim.api.nvim_create_autocmd("ColorScheme", {
      group   = vim.api.nvim_create_augroup("custom_highlights_edge", {}),
      pattern = "edge",
      callback = function()
        local config  = vim.fn["edge#get_configuration"]()
        local palette = vim.fn["edge#get_palette"](config.style, config.dim_foreground, config.colors_override)
        local set_hl  = vim.fn["edge#highlight"]
        set_hl("Search",    palette.none, palette.diff_blue)
        set_hl("IncSearch", palette.none, palette.diff_green)
        set_hl("CursorLine", palette.none, palette.bg2, "bold")
        set_hl("PmenuSel",  palette.blue, palette.none, "bold")
        set_hl("Visual",    palette.none, palette.bg2)
      end,
    })
    vim.cmd("colorscheme edge")
  ]],
          },

          -- Tokyo Dark Theme
          {
            name        = "Tokyo Dark",
            colorscheme = "tokyodark",
            before      = [[
    require("tokyodark").setup({
      transparent_background = true,
      gamma                 = 1.00,
      styles = {
        comments     = { italic = true },
        keywords     = { italic = true },
        identifiers  = { italic = true },
      },
      custom_highlights = function(highlights, palette)
        highlights.Comment    = { fg = palette.gray, italic = true }
        highlights.Keyword    = { fg = palette.magenta, bold   = true }
        highlights.Function   = { fg = palette.blue }
        highlights.Identifier = { fg = palette.cyan, italic = true }
        highlights.Variable   = { fg = palette.orange }
        return highlights
      end,
      custom_palette = function(palette)
        palette.gray    = "#4A4A4A"
        palette.magenta = "#D16D9E"
        palette.blue    = "#569CD6"
        palette.cyan    = "#4EC9B0"
        palette.orange  = "#D19A66"
        return palette
      end,
      terminal_colors = true,
    })
    vim.cmd("colorscheme tokyodark")
  ]],
          },

          -- Nightfox Theme
          {
            name        = "Nightfox",
            colorscheme = "nightfox",
            before      = [[
    require("nightfox").setup({
      options = {
        transparent     = true,
        terminal_colors = true,
        styles = {
          comments  = "italic",
          keywords  = "bold",
          functions = "italic,bold",
        },
      },
    })
    vim.cmd("colorscheme nightfox")
  ]],
          },

          -- Carbonfox Theme
          {
            name        = "Carbonfox",
            colorscheme = "carbonfox",
            before      = [[
    require("nightfox").setup({
      options = {
        transparent     = true,
        terminal_colors = true,
        styles = {
          comments  = "italic",
          keywords  = "bold",
          functions = "italic,bold",
        },
      },
    })
    vim.cmd("colorscheme carbonfox")
  ]],
          },

          -- Nordic Dark Theme
          {
            name        = "Nordic Dark",
            colorscheme = "nordic",
            before      = [[
    require("nordic").setup({
      bold_keywords       = false,
      italic_comments     = true,
      transparent = { bg = true, float = false },
      bright_border       = false,
      reduced_blue        = true,
      swap_backgrounds    = false,
      cursorline = { bold = false, bold_number = true, theme = "dark", blend = 0.85 },
      noice      = { style = "classic" },
      telescope  = { style = "flat" },
      leap       = { dim_backdrop = false },
      ts_context = { dark_background = true },
    })
    require("nordic").load()
  ]],
          },

          -- Dracula Theme
          {
            name        = "Dracula",
            colorscheme = "dracula",
            before      = [[
    local dracula = require("dracula")
    dracula.setup({
      colors = {
        bg             = "#282A36",
        fg             = "#F8F8F2",
        selection      = "#44475A",
        comment        = "#6272A4",
        red            = "#FF5555",
        orange         = "#FFB86C",
        yellow         = "#F1FA8C",
        green          = "#50fa7b",
        purple         = "#BD93F9",
        cyan           = "#8BE9FD",
        pink           = "#FF79C6",
        bright_red     = "#FF6E6E",
        bright_green   = "#69FF94",
        bright_yellow  = "#FFFFA5",
        bright_blue    = "#D6ACFF",
        bright_magenta = "#FF92DF",
        bright_cyan    = "#A4FFFF",
        bright_white   = "#FFFFFF",
        menu           = "#21222C",
        visual         = "#3E4452",
        gutter_fg      = "#4B5263",
        nontext        = "#3B4048",
        white          = "#ABB2BF",
        black          = "#191A21",
      },
      show_end_of_buffer = true,
      transparent_bg     = true,
      lualine_bg_color   = "#44475a",
      italic_comment     = true,
      overrides          = {
        NonText = { fg = "#6272A4" },
      },
    })
  ]],
          },

          -- Solarized Osaka Theme
          {
            name        = "Solarized Osaka",
            colorscheme = "solarized-osaka",
            before      = [[
    require("solarized-osaka").setup({
      transparent       = true,
      terminal_colors   = true,
      styles = {
        comments    = { italic = true },
        keywords    = { italic = true },
        functions   = {},
        variables   = {},
        sidebars    = "dark",
        floats      = "dark",
      },
      sidebars          = { "qf","help","vista_kind","terminal","packer" },
      day_brightness    = 0.3,
      hide_inactive_statusline = false,
      dim_inactive      = false,
      lualine_bold      = false,
      on_colors = function(colors)
        colors.hint  = colors.orange
        colors.error = "#ff0000"
      end,
      on_highlights = function(hl, colors)
        local prompt = "#2d3149"
        hl.TelescopeNormal        = { bg = colors.bg_dark, fg = colors.fg_dark }
        hl.TelescopeBorder        = { bg = colors.bg_dark, fg = colors.bg_dark }
        hl.TelescopePromptNormal  = { bg = prompt }
        hl.TelescopePromptBorder  = { bg = prompt, fg = prompt }
        hl.TelescopePromptTitle   = { bg = prompt, fg = prompt }
        hl.TelescopePreviewTitle  = { bg = colors.bg_dark, fg = colors.bg_dark }
        hl.TelescopeResultsTitle  = { bg = colors.bg_dark, fg = colors.bg_dark }
      end,
    })
  ]],
          },

          -- Everforest Theme
          {
            name        = "Everforest",
            colorscheme = "everforest",
            before      = [[
    require("everforest").setup({
      background               = "dark",
      transparent_background   = true,
      dim_inactive_windows     = true,
      disable_italic_comments  = false,
      enable_italic            = true,
      cursor                   = "block",
      sign_column_background   = "none",
      spell_foreground         = "underline",
      ui_contrast              = "high",
      show_eob                 = false,
      current_word             = "underline",
      diagnostic_text_highlight= true,
      diagnostic_line_highlight= false,
      diagnostic_virtual_text  = true,
      disable_terminal_colours = false,
      colours_override = function(palette)
        palette.red = "#b86466"
      end,
      on_highlights = function(hl, palette)
        hl.DiagnosticError = { fg = palette.red, bg = palette.none, sp = palette.red }
        hl.DiagnosticWarn  = { fg = palette.yellow, bg = palette.none, sp = palette.yellow }
        hl.DiagnosticInfo  = { fg = palette.blue, bg = palette.none, sp = palette.blue }
        hl.DiagnosticHint  = { fg = palette.green, bg = palette.none, sp = palette.green }
        hl.TSBoolean      = { fg = palette.purple, bg = palette.none, bold = true }
      end,
    })
    require("everforest").load()
  ]],
          },

          -- Sonokai Themes
          {
            name        = "Sonokai Default",
            colorscheme = "sonokai",
            before      = [[
    vim.g.sonokai_style                = "default"
    vim.g.sonokai_enable_italic        = 1
    vim.g.sonokai_transparent_background=0
  ]],
          },
          {
            name        = "Sonokai Atlantis",
            colorscheme = "sonokai",
            before      = [[
    vim.g.sonokai_style                = "atlantis"
    vim.g.sonokai_enable_italic        = 1
    vim.g.sonokai_transparent_background=1
  ]],
          },
          {
            name        = "Sonokai Andromeda",
            colorscheme = "sonokai",
            before      = [[
    vim.g.sonokai_style                = "andromeda"
    vim.g.sonokai_enable_italic        = 1
    vim.g.sonokai_transparent_background=1
  ]],
          },
          {
            name        = "Sonokai Shusia",
            colorscheme = "sonokai",
            before      = [[
    vim.g.sonokai_style                = "shusia"
    vim.g.sonokai_enable_italic        = 1
    vim.g.sonokai_transparent_background=1
  ]],
          },
          {
            name        = "Sonokai Maia",
            colorscheme = "sonokai",
            before      = [[
    vim.g.sonokai_style                = "maia"
    vim.g.sonokai_enable_italic        = 1
    vim.g.sonokai_transparent_background=1
  ]],
          },
          {
            name        = "Sonokai Espresso",
            colorscheme = "sonokai",
            before      = [[
    vim.g.sonokai_style                = "espresso"
    vim.g.sonokai_enable_italic        = 1
    vim.g.sonokai_transparent_background=1
  ]],
          },

          -- Custom Theme (from colors/)
          {
            name        = "Custom",
            colorscheme = "custom",
            before      = [[
    vim.opt.rtp:append(vim.fn.stdpath("config") .. "/lua/migbyte/plugins")
    vim.opt.termguicolors = true
    vim.cmd("colorscheme custom")
  ]],
          },

          -- Dosbox Black Theme (from colors/)
          {
            name        = "Dosbox Black",
            colorscheme = "dosbox-black",
            before      = [[
    vim.opt.rtp:append(vim.fn.stdpath("config") .. "/lua/migbyte/plugins")
    vim.opt.termguicolors = true
    vim.cmd("colorscheme dosbox-black")
  ]],
          },

          -- Dosbox Theme (from colors/)
          {
            name        = "Dosbox",
            colorscheme = "dosbox",
            before      = [[
    vim.opt.rtp:append(vim.fn.stdpath("config") .. "/lua/migbyte/plugins")
    vim.opt.termguicolors = true
    vim.cmd("colorscheme dosbox")
  ]],
          },

        }, -- end themes

        livePreview  = true,
        globalBefore = [[
          vim.cmd("highlight clear")
          vim.o.termguicolors = true
        ]],
      }) -- end themery.setup()

      -- Keymaps
      vim.keymap.set("n", "<leader>cm", function() vim.cmd("Themery") end,
        { noremap = true, desc = "Open Themery Menu" })
      vim.keymap.set("n", "<leader>cl", function()
        local themery      = require("themery")
        local currentTheme = themery.getCurrentTheme()
        if currentTheme and currentTheme.name == "Gruvbox Light" then
          themery.setThemeByName("Gruvbox Dark", true)
        else
          themery.setThemeByName("Gruvbox Light", true)
        end
      end, { noremap = true, desc = "Toggle Light/Dark Theme" })

      -- Re-apply the last selected theme on startup
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local themery = require("themery")
          local current = themery.getCurrentTheme()
          if current and current.colorscheme then
            vim.cmd("colorscheme " .. current.colorscheme)
          end
        end,
      })
    end,
  },
}
