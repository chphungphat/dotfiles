return {
  "neovim/nvim-lspconfig",
  init = function()
    vim.lsp.config("marksman", {
      filetypes = { "markdown", "markdown.mdx" },
    })
    vim.lsp.enable("marksman")

    vim.lsp.config("taplo", {
      filetypes = { "toml" },
    })
    vim.lsp.enable("taplo")
  end,
}
