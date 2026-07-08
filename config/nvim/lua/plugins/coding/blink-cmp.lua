return {
  "saghen/blink.cmp",
  dependencies = {
    "folke/lazydev.nvim",
    "echasnovski/mini.icons",
    "rafamadriz/friendly-snippets",
    -- "fang2hou/blink-copilot",
  },
  version = "1.*",
  build = "cargo build --release",

  opts = {
    keymap = {
      preset = "none",
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer", "lazydev" },

      min_keyword_length = 1,

      per_filetype = {
        typescript = { "lsp", "path", "snippets" },
        typescriptreact = { "lsp", "path", "snippets" },
        javascript = { "lsp", "path", "snippets" },
        javascriptreact = { "lsp", "path", "snippets" },
        ["typescript.tsx"] = { "lsp", "path", "snippets" },
        ["javascript.jsx"] = { "lsp", "path", "snippets" },
      },

      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
        buffer = {
          score_offset = -5,
          opts = {
            max_sync_buffer_size = 10000,
            max_async_buffer_size = 80000,
          },
        },
        -- copilot = {
        --   name = "copilot",
        --   module = "blink-copilot",
        --   async = true,
        -- },
      },
    },

    completion = {
      accept = {
        auto_brackets = { enabled = true },
      },

      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },

      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = "rounded",
          max_width = 80,
          max_height = 20,
        },
      },

      menu = {
        auto_show = true,
        border = "rounded",
        draw = {
          columns = {
            { "kind_icon", gap = 1 },
            { "label",     "label_description", gap = 1 },
            { "kind" },
          },
        },
      },

      ghost_text = { enabled = false },
    },

    signature = { enabled = true },

    appearance = {
      nerd_font_variant = "normal",
    },

    fuzzy = {
      implementation = "prefer_rust_with_warning",
      sorts = { "exact", "score", "sort_text" },
    },
  },
  opts_extend = { "sources.default" },

  config = function(_, opts)
    require("blink.cmp").setup(opts)
  end,
}
