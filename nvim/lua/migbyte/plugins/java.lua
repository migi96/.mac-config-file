-- ============================================================================
-- NVIM-JAVA - Zero-config Java IDE layer (JDTLS + DAP + tests)
-- ============================================================================
-- Replaces a BlueJ-style workflow with a full terminal Java toolchain:
--   * Eclipse JDT Language Server (completion, diagnostics, refactors)
--   * java-debug-adapter + java-test (debugging & running JUnit)
--   * Lombok + Spring Boot tooling
--
-- Requirements (verified against upstream, 2026-06):
--   * Neovim 0.11.5+              (you are on 0.11.5)
--   * JDTLS 1.43.0 + JDK 17       (auto-installed via Mason on first run)
--
-- IMPORTANT ORDER GUARANTEE:
--   `require("java").setup()` MUST run before `vim.lsp.enable("jdtls")`.
--   jdtls is intentionally EXCLUDED from mason-lspconfig's automatic_enable
--   (see lsp.lua) so this plugin is the sole owner of the jdtls config.
-- ============================================================================

return {
  "nvim-java/nvim-java",
  dependencies = {
    -- Spring Boot tooling. Pinned to the commit upstream nvim-java tests
    -- against; spring-boot.nvim's API has broken on HEAD before.
    { "JavaHello/spring-boot.nvim", commit = "218c0c26c14d99feca778e4d13f5ec3e8b1b60f0" },
    "MunifTanjim/nui.nvim",
    "mfussenegger/nvim-dap",
    -- Already present elsewhere in the config; declared so lazy guarantees
    -- they load before nvim-java's setup runs.
    "neovim/nvim-lspconfig",
    "mason-org/mason.nvim",
  },

  config = function()
    -- Registers the jdtls LSP config (bundles for DAP, lombok, spring-boot)
    -- and queues Mason installs for jdtls / JDK 17 / java-test / debug adapter.
    require("java").setup({
      -- Defaults are sensible. Override here if you need a specific runtime,
      -- e.g.:
      -- jdk = { auto_install = true, version = "17" },
      -- jdtls = { version = "1.43.0" },
    })

    -- Neovim 0.11+ way to turn the LSP on. Must come AFTER java.setup().
    vim.lsp.enable("jdtls")

    -- ------------------------------------------------------------------------
    -- Java-only keymaps (buffer-local, mirrors the LspAttach style in lsp.lua)
    -- ------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      group = vim.api.nvim_create_augroup("migbyte-java-keys", { clear = true }),
      callback = function(ev)
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc, silent = true })
        end
        -- Run / build
        map("<leader>jr", "<cmd>JavaRunnerRunMain<cr>",        "Java: Run main()")
        map("<leader>js", "<cmd>JavaRunnerStopMain<cr>",       "Java: Stop runner")
        map("<leader>jb", "<cmd>JavaBuildBuildWorkspace<cr>",  "Java: Build workspace")
        -- Tests
        map("<leader>jtc", "<cmd>JavaTestRunCurrentClass<cr>",  "Java: Test current class")
        map("<leader>jtm", "<cmd>JavaTestRunCurrentMethod<cr>", "Java: Test current method")
        map("<leader>jtr", "<cmd>JavaTestViewLastReport<cr>",   "Java: View last test report")
        -- Debug tests
        map("<leader>jdc", "<cmd>JavaTestDebugCurrentClass<cr>",  "Java: Debug current class")
        map("<leader>jdm", "<cmd>JavaTestDebugCurrentMethod<cr>", "Java: Debug current method")
        -- Runtime / settings
        map("<leader>jp", "<cmd>JavaProfileUI<cr>",             "Java: Profile manager")
        map("<leader>jR", "<cmd>JavaSettingsChangeRuntime<cr>", "Java: Change JDK runtime")
      end,
      desc = "nvim-java buffer-local keymaps",
    })
  end,
}
