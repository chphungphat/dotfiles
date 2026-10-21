return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    enable = true,
    max_lines = 3,
    min_window_height = 15,
    line_numbers = true,
    multiline_threshold = 2,
    trim_scope = "outer",
    mode = "cursor",
    separator = nil,
  },
  keys = {
    {
      "<leader>cx",
      function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end,
      desc = "Jump to Context Header",
    },
  },
}
