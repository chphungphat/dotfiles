return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  dependencies = {
    "echasnovski/mini.icons",
  },
  config = function(_, opts)
    require("mini.icons").setup()
    MiniIcons.mock_nvim_web_devicons()
    require("snacks").setup(opts)
  end,
  opts = {
    bigfile = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    indent = { enabled = true },
    words = { enabled = true },
    input = { enabled = true },
    rename = { enabled = true },
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 15, total = 150 },
        easing = "linear",
      },
      animate_repeat = {
        delay = 100,
        duration = { step = 5, total = 50 },
        easing = "linear",
      },
    },
  },
  keys = {
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
  },
}
