return {
  "ibhagwan/fzf-lua",
  opts = {
    winopts = {
      preview = {
        scrollbar = false,
      },
    },
    keymap = {
      fzf = {
        ["ctrl-u"] = "preview-half-page-up",
        ["ctrl-d"] = "preview-half-page-down",
      },
    },
    files = {
      hidden = false,
      no_ignore = false,
    },
    grep = {
      hidden = false,
      no_ignore = false,
      rg_glob = true,
    },
  },
  keys = {
    -- File and buffer navigation
    { "<leader><leader>", function() require("fzf-lua").files() end,    desc = "Search Files" },
    { "<leader>sg",       function() require("fzf-lua").git_files() end, desc = "Search Git Files" },
    { "<leader>sb",       function() require("fzf-lua").buffers() end,   desc = "Search Buffers" },
    { "<leader>so",       function() require("fzf-lua").oldfiles() end,  desc = "Search Old Files" },

    -- Grep
    { "<leader>/",  function() require("fzf-lua").live_grep() end,                    desc = "Search by Grep" },
    { "<leader>sc", function() require("fzf-lua").grep_cword() end,                   desc = "Search Word Under Cursor",  mode = "n" },
    { "<leader>sC", function() require("fzf-lua").grep_cWORD() end,                   desc = "Search WORD Under Cursor",  mode = "n" },
    { "<leader>sv", function() require("fzf-lua").grep_visual() end,                  desc = "Search Visual Selection",   mode = "v" },
    { "<leader>sr", function() require("fzf-lua").resume() end,                       desc = "Resume Last Search" },

    -- Diagnostics and lists
    { "<leader>sd", function() require("fzf-lua").diagnostics_document() end, desc = "Search Diagnostics" },
    { "<leader>sq", function() require("fzf-lua").quickfix() end,              desc = "Quickfix List" },
    { "<leader>sl", function() require("fzf-lua").loclist() end,               desc = "Location List" },

    -- Git
    { "<leader>gs", function() require("fzf-lua").git_status() end,    desc = "Git Status" },
    { "<leader>gc", function() require("fzf-lua").git_commits() end,   desc = "Git Commits" },
    { "<leader>gb", function() require("fzf-lua").git_bcommits() end,  desc = "Git Buffer Commits" },

    -- Help and navigation
    { "<leader>sh", function() require("fzf-lua").help_tags() end, desc = "Search Help Tags" },
    { "<leader>sk", function() require("fzf-lua").keymaps() end,   desc = "Search Keymaps" },
    { "<leader>sm", function() require("fzf-lua").marks() end,     desc = "Search Marks" },
  },
}
