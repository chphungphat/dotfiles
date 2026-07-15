return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if pcall(require, "blink.cmp") then
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(event)
        local opts = { buffer = event.buf, silent = true }

        vim.keymap.set("n", "gd", function()
          Snacks.picker.lsp_definitions()
        end, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration,
          vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gr", function()
          Snacks.picker.lsp_references()
        end, vim.tbl_extend("force", opts, { desc = "Show references" }))
        vim.keymap.set("n", "gi", function()
          Snacks.picker.lsp_implementations()
        end, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "gt", function()
          Snacks.picker.lsp_type_definitions()
        end, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))

        vim.keymap.set("n", "<leader>cs", function()
          Snacks.picker.lsp_symbols()
        end, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
        vim.keymap.set("n", "<leader>cS", function()
          Snacks.picker.lsp_workspace_symbols()
        end, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))

        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,
          vim.tbl_extend("force", opts, { desc = "Code actions" }))
        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename,
          vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover,
          vim.tbl_extend("force", opts, { desc = "Show hover documentation" }))

        vim.keymap.set("n", "[e", function()
          vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, count = -1 })
        end, vim.tbl_extend("force", opts, { desc = "Previous Error" }))
        vim.keymap.set("n", "]e", function()
          vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, count = 1 })
        end, vim.tbl_extend("force", opts, { desc = "Next Error" }))

        vim.keymap.set("n", "[d", function()
          vim.diagnostic.jump({
            severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.HINT, vim.diagnostic.severity.INFO },
            count = -1,
          })
        end, vim.tbl_extend("force", opts, { desc = "Previous Warning/Info/Hint" }))
        vim.keymap.set("n", "]d", function()
          vim.diagnostic.jump({
            severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.HINT, vim.diagnostic.severity.INFO },
            count = 1,
          })
        end, vim.tbl_extend("force", opts, { desc = "Next Warning/Info/Hint" }))

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client.name == "vtsls" then
          vim.keymap.set("n", "<leader>oi", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.organizeImports" }, diagnostics = {} },
            })
          end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
        end

        if client and client.name == "clangd" then
          vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>",
            vim.tbl_extend("force", opts, { desc = "Switch Source/Header (C/C++)" }))
        end
      end,
    })

    vim.lsp.config("*", { capabilities = capabilities })

    -- TypeScript / JavaScript
    vim.lsp.enable("vtsls")
    vim.lsp.config("vtsls", {
      filetypes = {
        "javascript", "javascriptreact", "javascript.jsx",
        "typescript", "typescriptreact", "typescript.tsx",
      },
      settings = {
        typescript = {
          tsserver = {
            maxTsServerMemory = 8192,
            nodePath = "node",
          },
          inlayHints = {
            parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = false },
            parameterTypes = { enabled = true },
            variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues = { enabled = true },
          },
          preferences = {
            importModuleSpecifier = "shortest",
            importModuleSpecifierEnding = "auto",
            quoteStyle = "auto",
            useAliasesForRenames = true,
          },
          updateImportsOnFileMove = { enabled = "always" },
        },
        javascript = {
          inlayHints = {
            parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = false },
            parameterTypes = { enabled = true },
            variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues = { enabled = true },
          },
          preferences = {
            importModuleSpecifier = "shortest",
            importModuleSpecifierEnding = "auto",
            quoteStyle = "auto",
          },
          updateImportsOnFileMove = { enabled = "always" },
        },
        vtsls = {
          autoUseWorkspaceTsdk = true,
          experimental = {
            completion = { enableServerSideFuzzyMatch = true },
          },
        },
      },
    })

    -- Styles
    -- vim.lsp.enable("tailwindcss")
    -- vim.lsp.config("tailwindcss", {
    --   filetypes = {
    --     "html", "css", "scss",
    --     "javascript", "javascriptreact", "typescript", "typescriptreact",
    --     "vue", "svelte", "astro",
    --   },
    --   settings = {
    --     tailwindCSS = {
    --       experimental = { configFile = "src/themes/global.css" },
    --     },
    --   },
    -- })

    -- HTML / CSS
    vim.lsp.enable("html")
    vim.lsp.config("html", { filetypes = { "html" } })

    vim.lsp.enable("cssls")
    vim.lsp.config("cssls", { filetypes = { "css", "scss", "less" } })

    -- Data / Config
    vim.lsp.enable("jsonls")
    vim.lsp.config("jsonls", { filetypes = { "json", "jsonc" } })

    vim.lsp.enable("yamlls")
    vim.lsp.config("yamlls", { filetypes = { "yaml" } })

    -- Linting
    -- vim.lsp.enable("eslint")
    -- vim.lsp.config("eslint", {
    --   filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    --   settings = {
    --     format = false,
    --     experimental = { useFlatConfig = true },
    --     run = "onSave",
    --   },
    -- })
  end,
}
