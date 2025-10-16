return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.inlay_hints = vim.tbl_deep_extend("force", opts.inlay_hints or {}, {
      enabled = false,
    })

    opts.servers.bashls = vim.tbl_deep_extend("force", opts.servers.bashls or {}, {
      handlers = {
        ["textDocument/publishDiagnostics"] = function(err, res, ...)
          local file_name = vim.fn.fnamemodify(vim.uri_to_fname(res.uri), ":t")
          if not file_name:match("^%.env") then
            vim.lsp.diagnostic.on_publish_diagnostics(err, res, ...)
          end
        end,
      },
    })

    return opts
  end,
}
