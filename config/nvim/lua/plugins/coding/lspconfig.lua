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
        vim.keymap.set(
          "n",
          "gD",
          vim.lsp.buf.declaration,
          vim.tbl_extend("force", opts, { desc = "Go to declaration" })
        )
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

        vim.keymap.set(
          { "n", "v" },
          "<leader>ca",
          vim.lsp.buf.code_action,
          vim.tbl_extend("force", opts, { desc = "Code actions" })
        )
        vim.keymap.set(
          "n",
          "<leader>cr",
          vim.lsp.buf.rename,
          vim.tbl_extend("force", opts, { desc = "Rename symbol" })
        )

        vim.keymap.set(
          "n",
          "K",
          vim.lsp.buf.hover,
          vim.tbl_extend("force", opts, { desc = "Show hover documentation" })
        )

        vim.keymap.set("n", "[e", function()
          vim.diagnostic.jump({
            severity = vim.diagnostic.severity.ERROR,
            count = -1,
          })
        end, vim.tbl_extend("force", opts, { desc = "Previous Error" }))
        vim.keymap.set("n", "]e", function()
          vim.diagnostic.jump({
            severity = vim.diagnostic.severity.ERROR,
            count = 1,
          })
        end, vim.tbl_extend("force", opts, { desc = "Next Error" }))

        vim.keymap.set("n", "[d", function()
          vim.diagnostic.jump({
            severity = {
              vim.diagnostic.severity.WARN,
              vim.diagnostic.severity.HINT,
              vim.diagnostic.severity.INFO,
            },
            count = -1,
          })
        end, vim.tbl_extend("force", opts, { desc = "Previous Warning/Info/Hint" }))
        vim.keymap.set("n", "]d", function()
          vim.diagnostic.jump({
            severity = {
              vim.diagnostic.severity.WARN,
              vim.diagnostic.severity.HINT,
              vim.diagnostic.severity.INFO,
            },
            count = 1,
          })
        end, vim.tbl_extend("force", opts, { desc = "Next Warning/Info/Hint" }))

        vim.keymap.set(
          "n",
          "<leader>cd",
          vim.diagnostic.open_float,
          vim.tbl_extend("force", opts, { desc = "Show diagnostic" })
        )

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.name == "ts_ls" then
          vim.keymap.set("n", "<leader>oi", function()
            vim.lsp.buf.execute_command({
              command = "_typescript.organizeImports",
              arguments = { vim.api.nvim_buf_get_name(0) },
            })
          end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
        end

        -- C/C++ specific keymaps
        if client and client.name == "clangd" then
          vim.keymap.set(
            "n",
            "<leader>ch",
            "<cmd>ClangdSwitchSourceHeader<cr>",
            vim.tbl_extend("force", opts, { desc = "Switch Source/Header (C/C++)" })
          )
        end
      end,
    })

    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    vim.lsp.enable("lua_ls")
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })

    vim.lsp.enable("ts_ls")
    vim.lsp.config("ts_ls", {
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
          suggest = {
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            includeCompletionsWithInsertText = true,
            includeCompletionsWithSnippetText = true,
            includeAutomaticOptionalChainCompletions = true,
          },
          preferences = {
            includePackageJsonAutoImports = "auto",
            importModuleSpecifier = "shortest",
            importModuleSpecifierEnding = "auto",
            quoteStyle = "auto",
            useAliasesForRenames = true,
          },
          updateImportsOnFileMove = {
            enabled = "always",
          },
          workspaceSymbols = {
            scope = "allOpenProjects",
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
          suggest = {
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            includeCompletionsWithInsertText = true,
            includeCompletionsWithSnippetText = true,
            includeAutomaticOptionalChainCompletions = true,
          },
          preferences = {
            includePackageJsonAutoImports = "auto",
            importModuleSpecifier = "shortest",
            importModuleSpecifierEnding = "auto",
            quoteStyle = "auto",
            useAliasesForRenames = true,
          },
          updateImportsOnFileMove = {
            enabled = "always",
          },
        },
      },
    })

    -- clangd
    vim.lsp.enable("clangd")
    vim.lsp.config("clangd", {
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
      capabilities = vim.tbl_extend("force", capabilities, {
        offsetEncoding = { "utf-16" },
      }),
    })

    -- vim.lsp.enable("eslint")
    vim.lsp.config("eslint", {
      settings = {
        format = false,
        experimental = {
          useFlatConfig = true,
        },
      },
    })

    vim.lsp.enable("bashls")
    vim.lsp.config("bashls", {})

    vim.lsp.enable("jsonls")
    vim.lsp.config("jsonls", {})

    vim.lsp.enable("yamlls")
    vim.lsp.config("yamlls", {})

    vim.lsp.enable("html")
    vim.lsp.config("html", {})

    vim.lsp.enable("cssls")
    vim.lsp.config("cssls", {})

    vim.lsp.enable("marksman")
    vim.lsp.config("marksman", {})

    vim.lsp.enable("dockerls")
    vim.lsp.config("dockerls", {})

    vim.lsp.enable("docker_compose_language_service")
    vim.lsp.config("docker_compose_language_service", {})

    vim.lsp.enable("taplo")
    vim.lsp.config("taplo", {})

    vim.lsp.enable("gitlab_ci_ls")
    vim.lsp.config("gitlab_ci_ls", {})

    vim.lsp.enable("tinymist")
    vim.lsp.config("tinymist", {})

    vim.lsp.enable("astro")
    local node_path = vim.fn.exepath("node")
    if node_path ~= "" then
      local node_dir = vim.fn.fnamemodify(vim.fn.resolve(node_path), ":h:h")
      local tsdk = node_dir .. "/lib/node_modules/typescript/lib"
      if vim.uv.fs_stat(tsdk) then
        vim.lsp.config("astro", {
          init_options = {
            typescript = { tsdk = tsdk },
          },
        })
      end
    end

    vim.lsp.enable("gdscript")
    vim.lsp.config("gdscript", {})
  end,
}
