return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    wk.add({
      -- <leader> prefix groups
      { "<leader>c", group = "code" },
      { "<leader>s", group = "search" },
      { "<leader>g", group = "git" },
      { "<leader>e", group = "explorer" },
      { "<leader>l", group = "log" },
      { "<leader>j", group = "java" },
      { "<leader>h", group = "help" },
      { "<leader>n", group = "neogen" },
      { "<leader>f", group = "format" },

      -- ] / [ navigation groups (individual bindings already have desc)
      { "]", group = "next" },
      { "[", group = "prev" },

      -- nvim-surround: plugin does not set desc, register manually
      { "ys",  desc = "Add surround",        mode = "n" },
      { "yss", desc = "Add surround (line)", mode = "n" },
      { "ds",  desc = "Delete surround",     mode = "n" },
      { "cs",  desc = "Change surround",     mode = "n" },
      { "S",   desc = "Surround selection",  mode = "v" },
    })
  end,
}
