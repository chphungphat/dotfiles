return {
  "danymat/neogen",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    snippet_engine = "nvim",
    languages = {
      typescript      = { template = { annotation_convention = "tsdoc" } },
      javascript      = { template = { annotation_convention = "jsdoc" } },
      typescriptreact = { template = { annotation_convention = "tsdoc" } },
      javascriptreact = { template = { annotation_convention = "jsdoc" } },
      cs              = { template = { annotation_convention = "xmldoc" } },
      c               = { template = { annotation_convention = "doxygen" } },
      cpp             = { template = { annotation_convention = "doxygen" } },
    },
  },
  keys = {
    {
      "<leader>nd",
      function() require("neogen").generate() end,
      desc = "Generate doc comment",
    },
    {
      "<leader>nf",
      function() require("neogen").generate({ type = "func" }) end,
      desc = "Generate function doc",
    },
    {
      "<leader>nc",
      function() require("neogen").generate({ type = "class" }) end,
      desc = "Generate class doc",
    },
    {
      "<leader>nt",
      function() require("neogen").generate({ type = "type" }) end,
      desc = "Generate type doc",
    },
  },
}
