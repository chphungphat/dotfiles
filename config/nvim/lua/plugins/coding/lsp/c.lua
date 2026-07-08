return {
  "neovim/nvim-lspconfig",
  init = function()
    vim.lsp.config("clangd", {
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      on_init = function(client)
        client.offset_encoding = "utf-16"
      end,
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
      },
    })
    vim.lsp.enable("clangd")
  end,
}
