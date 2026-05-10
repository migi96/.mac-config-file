return {
  "folke/flash.nvim",
  opts = {
    -- labels = "asdfghjklqwertyuiopzxcvbnm",
    labels = "arstgmneio",
    label = {
      rainbow   = { enabled = true },
      uppercase = false,
      current   = true,
      exclude   = "hjkli",
    },
    modes = {
      search = { enabled = true },
      char   = { enabled = true, jump_labels = true, multi_line = true },
    },
    jump = {
      autojump   = true, -- jump immediately without waiting for extra input
      dot_repeat = true,
    },
    highlight = {
      backdrop = true,
      matches  = true,
    },
  },
  keys = {
    { "s",          mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash Jump" },
    { "S",          mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
    { "<leader>jr", mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash (Yank Target)" },
    { "<leader>jt", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search Hybrid" },
    { "<leader>ja", mode = "c",               function() require("flash").toggle() end,            desc = "Toggle Flash Search in Command" },
    { "<leader>ny", mode = "n",               function() require("flash").toggle() end,            desc = "Toggle Flash Search manually" },
  },
}
