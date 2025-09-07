return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    local on_publish_diagnostics = vim.lsp.diagnostic.on_publish_diagnostics
    local bashls = opts.servers.bashls or {}
    opts.servers.bashls = vim.tbl_deep_extend("force", bashls, {
      handlers = {
        ["textDocument/publishDiagnostics"] = function(err, res, ...)
          local file_name = vim.fn.fnamemodify(vim.uri_to_fname(res.uri), ":t")
          if string.match(file_name, "^%.env") == nil then
            return on_publish_diagnostics(err, res, ...)
          end
        end,
      },
    })
  end,
}
