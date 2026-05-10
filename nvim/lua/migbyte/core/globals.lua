-- Global settings for rest.nvim
vim.g.rest_nvim = {
  request = {
    skip_ssl_verification = false,
    hooks = {
      encode_url = true,
      user_agent = "rest.nvim",
      set_content_type = true,
    },
  },
  response = {
    hooks = { decode_url = true, format = true },
  },
  clients = {
    curl = {
      statistics = {
        { id = "time_total",    winbar = "take", title = "Time taken" },
        { id = "size_download", winbar = "size", title = "Download size" },
      },
      opts = { set_compressed = false, certificates = {} },
    },
  },
  cookies = {
    enable = true,
    path = vim.fs.joinpath(vim.fn.stdpath("data"), "rest-nvim.cookies"),
  },
  env = {
    enable = true,
    pattern = ".*%.env.*",
  },
  ui = {
    winbar = true,
    keybinds = { prev = "H", next = "L" },
  },
  highlight = {
    enable = true,
    timeout = 750,
  },
  _log_level = vim.log.levels.WARN,
}
