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
      enabled = false,
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
    zen = { enabled = true },
    explorer = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          layout = {
            preset = "sidebar",
            preview = false,
            layout = { width = 40 },
          },
          win = {
            list = {
              keys = {
                ["W"] = { { "pick_win", "jump" }, desc = "Pick Window" },
              },
            },
          },
        },
      },
    },
    lazygit = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = table.concat({
          "  █████╗ ██████╗ ███████╗    ██╗   ██╗ ██████╗ ██╗   ██╗",
          " ██╔══██╗██╔══██╗██╔════╝    ╚██╗ ██╔╝██╔═══██╗██║   ██║",
          " ███████║██████╔╝█████╗       ╚████╔╝ ██║   ██║██║   ██║",
          " ██╔══██║██╔══██╗██╔══╝        ╚██╔╝  ██║   ██║██║   ██║",
          " ██║  ██║██║  ██║███████╗       ██║   ╚██████╔╝╚██████╔╝",
          " ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝       ╚═╝    ╚═════╝  ╚═════╝",
          " ██████╗ ███████╗ █████╗ ██████╗ ██╗   ██╗██████╗        ",
          " ██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝╚════██╗       ",
          " ██████╔╝█████╗  ███████║██║  ██║ ╚████╔╝   ▄███╔╝       ",
          " ██╔══██╗██╔══╝  ██╔══██║██║  ██║  ╚██╔╝    ▀▀══╝        ",
          " ██║  ██║███████╗██║  ██║██████╔╝   ██║     ██╗          ",
          " ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝     ╚═╝          ",
          "",
          "         Damn right I am.                                ",
        }, "\n"),
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
          { icon = " ", key = "/", desc = "Live Grep", action = ":lua Snacks.picker.grep()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
          { icon = " ", key = "e", desc = "Explorer", action = ":lua Snacks.explorer()" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        {
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          cwd = true,
          limit = 8,
          padding = 1,
        },
        { section = "startup" },
      },
    },
  },
  keys = {
    -- Explorer
    {
      "<leader>ee",
      function()
        Snacks.explorer()
      end,
      desc = "Toggle Explorer",
    },
    {
      "<leader>ef",
      function()
        Snacks.explorer.open()
      end,
      desc = "Focus Explorer",
    },

    -- File and buffer navigation
    {
      "<leader><leader>",
      function()
        Snacks.picker.files()
      end,
      desc = "Search Files",
    },
    {
      "<leader>sg",
      function()
        Snacks.picker.git_files()
      end,
      desc = "Search Git Files",
    },
    {
      "<leader>sb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Search Buffers",
    },
    {
      "<leader>so",
      function()
        Snacks.picker.recent()
      end,
      desc = "Search Recent Files",
    },

    -- Grep
    {
      "<leader>/",
      function()
        Snacks.picker.grep()
      end,
      desc = "Search by Grep",
    },
    {
      "<leader>sc",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Search Word Under Cursor",
      mode = "n",
    },
    {
      "<leader>sC",
      function()
        Snacks.picker.grep_word({ word = false })
      end,
      desc = "Search WORD Under Cursor",
      mode = "n",
    },
    {
      "<leader>sv",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Search Visual Selection",
      mode = "v",
    },
    {
      "<leader>sr",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume Last Search",
    },

    -- Diagnostics and lists
    {
      "<leader>sd",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "Search Diagnostics",
    },
    {
      "<leader>sq",
      function()
        Snacks.picker.qflist()
      end,
      desc = "Quickfix List",
    },
    {
      "<leader>sl",
      function()
        Snacks.picker.loclist()
      end,
      desc = "Location List",
    },

    -- Git
    {
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git Status",
    },
    {
      "<leader>gc",
      function()
        Snacks.picker.git_log()
      end,
      desc = "Git Commits",
    },
    {
      "<leader>gb",
      function()
        Snacks.picker.git_log_file()
      end,
      desc = "Git Buffer Commits",
    },

    -- Help and navigation
    {
      "<leader>sh",
      function()
        Snacks.picker.help()
      end,
      desc = "Search Help Tags",
    },
    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Search Keymaps",
    },
    {
      "<leader>sm",
      function()
        Snacks.picker.marks()
      end,
      desc = "Search Marks",
    },

    -- Rename
    {
      "<leader>cR",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File",
    },

    -- Zoom
    {
      "<leader>z",
      function()
        Snacks.zen.zoom()
      end,
      desc = "Toggle Zoom",
    },

    -- Lazygit
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>gz",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
  },
}
