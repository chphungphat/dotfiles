return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    modes = {
      search = {
        enabled = false, -- Keep standard / search untouched
      },
      char = {
        jump_labels = true,
      },
    },
  },
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash Jump",
    },
  },
}
