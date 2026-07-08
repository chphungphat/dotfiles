return {
  "neovim/nvim-lspconfig",
  init = function()
    vim.lsp.config("dockerls", {
      filetypes = { "dockerfile" },
    })
    vim.lsp.enable("dockerls")

    vim.lsp.config("docker_compose_language_service", {
      filetypes = { "yaml.docker-compose" },
    })
    vim.lsp.enable("docker_compose_language_service")
  end,
}
