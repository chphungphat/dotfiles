return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.folds = vim.tbl_deep_extend("force", opts.folds or {}, {
      enable = false,
    })
    return opts
  end,
}
