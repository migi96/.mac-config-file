return {
  -- Mason ---------------------------------------------------------------
  { "mason-org/mason.nvim",          config = function() require("mason").setup() end },
  { "mason-org/mason-lspconfig.nvim" }, -- <— new org; old slug still redirects but use this

  -- nvim-lspconfig -------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      { "j-hui/fidget.nvim", tag = "legacy", opts = {} },
      "RobertBrunhage/dart-tools.nvim",
    },

    config = function()
      --------------------------------------------------------------------
      -- Mason & mason-lspconfig (v2) ▼
      --------------------------------------------------------------------
      local mason_lspconfig = require("mason-lspconfig")
      local servers = {
        "intelephense",
        "html",
        "emmet_ls",
        "tailwindcss",
        "ts_ls",
        "lua_ls",
      }

      mason_lspconfig.setup({
        ensure_installed = servers,

        -- NEW: handlers table replaces setup_handlers ▼
        handlers = {
          -- default for every server we didn’t override
          function(name)
            require("lspconfig")[name].setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
            }
          end,

          -- Dart & Flutter (dart-tools)
          dart = function()
            require("dart-tools").setup {
              lsp = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                on_attach = function(_, _) end,
                settings = {
                  dart = {
                    analysisExcludedFolders = {},
                    updateImportsOnRename = true,
                  },
                },
              },
            }
          end,

          -- HTML inside Blade / PHP
          html = function()
            require("lspconfig").html.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              filetypes = { "html", "blade", "php" },
            }
          end,

          -- Emmet
          emmet_ls = function()
            require("lspconfig").emmet_ls.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              filetypes = {
                "html", "blade", "php",
                "css", "sass", "scss", "less",
                "javascriptreact", "typescriptreact",
              },
            }
          end,
        },
      })

      --------------------------------------------------------------------
      -- Diagnostics & key-maps (unchanged)
      --------------------------------------------------------------------
      vim.diagnostic.config({
        virtual_text     = true,
        signs            = true,
        underline        = true,
        update_in_insert = false,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("migbyte-lsp-keys", {}),
        callback = function(ev)
          local k = vim.keymap
          local opts = { buffer = ev.buf }
          k.set("n", "K", vim.lsp.buf.hover, opts)
          k.set("n", "gs", vim.lsp.buf.definition, opts)
          k.set("n", "gS", vim.lsp.buf.declaration, opts)
          k.set("n", "gi", vim.lsp.buf.implementation, opts)
          k.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          k.set({ "n", "v" }, "<leader>en", vim.lsp.buf.code_action, opts)
          k.set("n", "<leader>as", vim.diagnostic.open_float, opts)
          k.set("n", "]t", vim.diagnostic.goto_next, opts)
          k.set("n", "[t", vim.diagnostic.goto_prev, opts)
        end,
      })
    end,
  },
}
