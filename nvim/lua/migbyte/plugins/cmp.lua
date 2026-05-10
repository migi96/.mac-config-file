-- lua/migbyte/plugins/cmp.lua

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    -- AI assistant source
    "zbirenbaum/copilot-cmp",

    -- Snippet engine & sources
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",

    -- Other useful sources
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "dcampos/cmp-emmet-vim",

    -- UI enhancement
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- Load snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      -- Key mappings
      mapping = cmp.mapping.preset.insert({
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),

        -- This is the logic for your Tab key
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true }) -- Accept suggestion
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()       -- Jump in snippet
          else
            fallback()                     -- Fallback to normal Tab
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1) -- Jump back in snippet
          else
            fallback()       -- Fallback to normal Shift-Tab
          end
        end, { "i", "s" }),
      }),
      -- Completion sources
      sources = cmp.config.sources({
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
        { name = "emmet_vim" },
      }),
      -- UI formatting
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "…",
          -- Show the source of the completion
          menu = {
            copilot = "[AI]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
          },
        }),
      },
    })
  end,
}
