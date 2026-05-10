return {
  "ThePrimeagen/harpoon",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    local keymap = vim.keymap -- Alias for conciseness

    -- Configure Harpoon
    harpoon.setup({
      global_settings = {
        save_on_toggle = false,
        save_on_change = true,
        enter_on_sendcmd = false,
        tmux_autoclose_windows = false,
        excluded_filetypes = { "harpoon" },
        mark_branch = false,
        tabline = false,
      },
    })

    --====================================================================
    --                        File Navigation Mappings
    --====================================================================

    -- Custom text-based shortcuts for files 1-11
    -- These will be prefixed with <leader>h
    local file_nav_keys = {
      { key = "o",  index = 1,  desc = "File 1 (One)" },
      { key = "tw", index = 2,  desc = "File 2 (Two)" },
      { key = "th", index = 3,  desc = "File 3 (Three)" },
      { key = "fo", index = 4,  desc = "File 4 (Four)" },
      { key = "fi", index = 5,  desc = "File 5 (Five)" },
      { key = "si", index = 6,  desc = "File 6 (Six)" },
      { key = "se", index = 7,  desc = "File 7 (Seven)" },
      { key = "ei", index = 8,  desc = "File 8 (Eight)" },
      { key = "ni", index = 9,  desc = "File 9 (Nine)" },
      { key = "te", index = 10, desc = "File 10 (Ten)" },
      { key = "el", index = 11, desc = "File 11 (Eleven)" },
    }

    -- Apply the mappings: <leader>h + key
    -- Example: <leader>hth -> goes to file 3
    for _, map in ipairs(file_nav_keys) do
      keymap.set("n", "<leader>h" .. map.key, function()
        require("harpoon.ui").nav_file(map.index)
      end, { desc = "Harpoon: " .. map.desc })
    end

    --====================================================================
    --                        General Harpoon Mappings
    --====================================================================

    -- Add current file to Harpoon
    keymap.set("n", "<leader>nr", function()
      require("harpoon.mark").add_file()
    end, { desc = "Add file to Harpoon" })

    -- Remove current file from Harpoon
    -- Note: This uses 'r', which does not conflict with the number shortcuts above
    keymap.set("n", "<leader>hr", function()
      require("harpoon.mark").rm_file()
    end, { desc = "Remove file from Harpoon" })

    -- Toggle the quick menu
    keymap.set("n", "<leader>ni", function()
      require("harpoon.ui").toggle_quick_menu()
    end, { desc = "Toggle Harpoon menu" })

    --====================================================================
    --                        Buffer & Nav Mappings
    --====================================================================

    -- Buffer navigation shortcuts
    keymap.set("n", "<leader>bn", function()
      vim.cmd("bnext")
    end, { desc = "Go to next buffer" })

    keymap.set("n", "<leader>bp", function()
      vim.cmd("bprevious")
    end, { desc = "Go to previous buffer" })

    -- Harpoon navigation for next/previous marked files (cycling)
    keymap.set("n", "<leader>nf", function() require("harpoon.ui").nav_next() end,
      { desc = "Navigate to next Harpoon file" })
    keymap.set("n", "<leader>np", function() require("harpoon.ui").nav_prev() end,
      { desc = "Navigate to previous Harpoon file" })

    -- Exit Harpoon menu easily with <Space>nn
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "harpoon",
      callback = function()
        keymap.set("n", "<Space>nn", "<Cmd>q<CR>", { buffer = true, desc = "Exit Harpoon menu" })
      end,
    })
  end,
}
