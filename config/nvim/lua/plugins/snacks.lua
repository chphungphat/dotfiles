return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    picker = {
      enabled = true,
      win = {
        input = {
          keys = {
            ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
          },
        },
      },
      sources = {
        files = {
          hidden = false,
          no_ignore = false,
        },
        grep = {
          hidden = false,
          no_ignore = false,
        },
      },
    },
    -- Enable other useful snacks features
    bigfile = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- File and buffer navigation
    {
      "<leader><leader>",
      function()
        require("snacks").picker.files()
      end,
      desc = "Search Files",
    },
    {
      "<leader>sg",
      function()
        require("snacks").picker.git_files()
      end,
      desc = "Search Git Files",
    },
    {
      "<leader>sb",
      function()
        require("snacks").picker.buffers()
      end,
      desc = "Search Buffers",
    },
    {
      "<leader>so",
      function()
        require("snacks").picker.recent()
      end,
      desc = "Search Old Files",
    },

    -- Search and grep
    {
      "<leader>/",
      function()
        require("snacks").picker.grep()
      end,
      desc = "Search by Grep",
    },
    {
      "<leader>sc",
      function()
        require("snacks").picker.grep_word()
      end,
      desc = "Search Word Under Cursor",
      mode = "n",
    },
    {
      "<leader>sC",
      function()
        require("snacks").picker.grep_word({ mode = "WORD" })
      end,
      desc = "Search WORD Under Cursor",
      mode = "n",
    },
    {
      "<leader>sv",
      function()
        require("snacks").picker.grep_word()
      end,
      desc = "Search Visual Selection",
      mode = "v",
    },
    {
      "<leader>sr",
      function()
        require("snacks").picker.resume()
      end,
      desc = "Resume Last Search",
    },

    -- Diagnostics
    {
      "<leader>sd",
      function()
        require("snacks").picker.diagnostics_buffer()
      end,
      desc = "Search Diagnostics",
    },

    -- Quickfix and location lists
    {
      "<leader>sq",
      function()
        require("snacks").picker.qflist()
      end,
      desc = "Quickfix List",
    },
    {
      "<leader>sl",
      function()
        require("snacks").picker.loclist()
      end,
      desc = "Location List",
    },

    -- Git
    {
      "<leader>gs",
      function()
        require("snacks").picker.git_status()
      end,
      desc = "Git Status",
    },
    {
      "<leader>gc",
      function()
        require("snacks").picker.git_log()
      end,
      desc = "Git Commits",
    },
    {
      "<leader>gb",
      function()
        require("snacks").picker.git_log_file()
      end,
      desc = "Git Buffer Commits",
    },

    -- Help and configuration
    {
      "<leader>sh",
      function()
        require("snacks").picker.help()
      end,
      desc = "Search Help Tags",
    },
    {
      "<leader>sk",
      function()
        require("snacks").picker.keymaps()
      end,
      desc = "Search Keymaps",
    },
    {
      "<leader>sm",
      function()
        require("snacks").picker.marks()
      end,
      desc = "Search Marks",
    },
  },
}
