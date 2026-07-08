return {
  "neovim/nvim-lspconfig",
  init = function()
    vim.lsp.config("bashls", {
      filetypes = { "sh", "bash" },
    })
    vim.lsp.enable("bashls")
  end,
}
