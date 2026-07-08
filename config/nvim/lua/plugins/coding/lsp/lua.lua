return {
  "neovim/nvim-lspconfig",
  init = function()
    vim.lsp.config("lua_ls", {
      filetypes = { "lua" },
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.enable("lua_ls")
  end,
}
