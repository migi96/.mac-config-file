return {
  {
    "leath-dub/snipe.nvim",
    keys = {
      {
        "<leader>sn",
        function()
          require("snipe").open_buffer_menu()
        end,
        desc = "Open Snipe buffer menu",
      },
    },
    opts = {
      ui = {
        max_height        = -1,        -- -1 means dynamic height
        -- position          = "center",  -- now centered
        position          = "topleft", -- now centered
        open_win_override = {
          border = "single",           -- Use "rounded" for rounded border
        },
        preselect_current = false,
        preselect         = nil,
        text_align        = "left",
      },
      hints = {
        dictionary = "sadflewcmpghio", -- Characters for hints
      },
      navigate = {
        next_page    = "J",
        prev_page    = "K",
        under_cursor = "<cr>",
        cancel_snipe = "<esc>",
        close_buffer = "D",
        open_vsplit  = "V",
        open_split   = "H",
        change_tag   = "C",
      },
      sort = "default", -- Default sort order for buffers
    },
  },
}
