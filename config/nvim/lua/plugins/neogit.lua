return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "ibhagwan/fzf-lua",
  },
  opts = {
    integrations = {
      diffview = true,
      fzf_lua = true,
    },
  },
  keys = {
    { "<leader>gg", function() require("neogit").open() end, desc = "Neogit" },
  },
}
