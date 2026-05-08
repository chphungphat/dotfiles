return {
  "saghen/blink.cmp",
  dependencies = {
    "folke/lazydev.nvim",
    "echasnovski/mini.icons",
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
      default = { "lsp", "path", "buffer", "lazydev" },

      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
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
      implementation = "rust",
      sorts = { "exact", "score", "sort_text" },
    },
  },
  opts_extend = { "sources.default" },

  config = function(_, opts)
    require("blink.cmp").setup(opts)
  end,
}
