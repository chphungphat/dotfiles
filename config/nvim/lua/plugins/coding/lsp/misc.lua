return {
  "neovim/nvim-lspconfig",
  init = function()
    -- Godot
    vim.lsp.config("gdscript", {
      filetypes = { "gdscript", "gd" },
    })
    vim.lsp.enable("gdscript")

    -- Typst
    vim.lsp.config("tinymist", {
      filetypes = { "typst" },
    })
    vim.lsp.enable("tinymist")

    -- GitLab CI
    vim.lsp.config("gitlab_ci_ls", {
      filetypes = { "yaml.gitlab" },
    })
    vim.lsp.enable("gitlab_ci_ls")

    -- Astro
    local node_path = vim.fn.exepath("node")
    if node_path ~= "" then
      local node_dir = vim.fn.fnamemodify(vim.fn.resolve(node_path), ":h:h")
      local tsdk = node_dir .. "/lib/node_modules/typescript/lib"
      if vim.uv.fs_stat(tsdk) then
        vim.lsp.config("astro", {
          filetypes = { "astro" },
          init_options = { typescript = { tsdk = tsdk } },
        })
        vim.lsp.enable("astro")
      end
    end
  end,
}
