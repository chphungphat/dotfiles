return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if pcall(require, "blink.cmp") then
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
    end
    -- Monorepo optimization: disable LSP dynamic file watching to avoid spawning
    -- thousands of recursive file system watchers in large workspaces.
    if capabilities.workspace then
      capabilities.workspace.didChangeWatchedFiles = {
        dynamicRegistration = false,
      }
    end

    -- Suppress unhandled VSCode client commands from vtsls
    vim.lsp.commands["_typescript.didOrganizeImports"] = function() end

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

        if client and (client.name == "vtsls" or client.name == "tsc") then
          vim.keymap.set("n", "<leader>oi", function()
            local bufnr = vim.api.nvim_get_current_buf()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.organizeImports" }, diagnostics = {} },
            })
            -- Re-format immediately with conform (oxfmt/prettierd) so the imports follow the project's format without a save
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(bufnr) then
                local ok, conform = pcall(require, "conform")
                if ok then
                  conform.format({ bufnr = bufnr, async = true, lsp_format = "fallback" })
                end
              end
            end, 150)
          end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
        end
        if client and client.name == "clangd" then
          vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>",
            vim.tbl_extend("force", opts, { desc = "Switch Source/Header (C/C++)" }))
        end
      end,
    })

    vim.lsp.config("*", { capabilities = capabilities })

    -- TypeScript / JavaScript: the native TypeScript 7 server (`tsgo --lsp`, lspconfig's "tsc") where
    -- the workspace prefers it (see core.workspace.prefers_native_ts), vtsls everywhere else.
    -- In nx-seller every package type-checks @nx/core from source (~4900 files per program):
    -- tsserver needed 0.7-5.5 s per edit for diagnostics and stalled completion behind them,
    -- tsgo answers in ~0.4 s. Install: `npm i -g @typescript/native-preview`.
    local vtsls_root_dir = vim.lsp.config.vtsls.root_dir
    vim.lsp.enable("tsc")
    vim.lsp.config("tsc", {
      cmd = function(dispatchers, config)
        local root = config.root_dir or vim.fn.getcwd()
        local bin = require("core.workspace").find_node_bin(root, "tsgo") or "tsgo"
        return vim.lsp.rpc.start({ bin, "--lsp", "--stdio" }, dispatchers, { cwd = root })
      end,
      root_dir = function(bufnr, on_dir)
        local root = require("core.workspace").prefers_native_ts(vim.api.nvim_buf_get_name(bufnr))
        if root then
          on_dir(root)
        end
      end,
      settings = {
        typescript = { preferences = { importModuleSpecifier = "non-relative" } },
        javascript = { preferences = { importModuleSpecifier = "non-relative" } },
      },
    })

    vim.lsp.enable("vtsls")
    vim.lsp.config("vtsls", {
      filetypes = {
        "javascript", "javascriptreact", "javascript.jsx",
        "typescript", "typescriptreact", "typescript.tsx",
      },
      root_dir = function(bufnr, on_dir)
        if require("core.workspace").prefers_native_ts(vim.api.nvim_buf_get_name(bufnr)) then
          return
        end
        vtsls_root_dir(bufnr, on_dir)
      end,
      -- A monorepo root may have no TypeScript of its own (projects install their own): point the
      -- workspace TypeScript at the one nearest the buffer that started the server, else the root's.
      before_init = function(_, config)
        local workspace = require("core.workspace")
        local tsdk = workspace.typescript_lib(vim.api.nvim_buf_get_name(0))
          or (config.root_dir and workspace.typescript_lib(vim.fs.joinpath(config.root_dir, "package.json")))
        if tsdk then
          config.settings.typescript = config.settings.typescript or {}
          config.settings.typescript.tsdk = tsdk
        end
      end,
      settings = {
        typescript = {
          format = {
            indentSize = 2,
            tabSize = 2,
            convertTabsToSpaces = true,
          },
          tsserver = {
            maxTsServerMemory = 8192,
            nodePath = "node",
            watchOptions = {
              watchFile = "useFsEvents",
              watchDirectory = "useFsEvents",
              fallbackPolling = "dynamicPriority",
              excludeDirectories = { "**/node_modules", "**/dist", "**/.nx", "**/.git", "**/build", "**/coverage" },
            },
            experimental = {
              enableProjectDiagnostics = false,
            },
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
            -- Prefer a non-relative path (`#src/...`, `@/...`) when the project maps one; relative otherwise.
            importModuleSpecifier = "non-relative",
            importModuleSpecifierEnding = "auto",
            quoteStyle = "auto",
            useAliasesForRenames = true,
          },
          updateImportsOnFileMove = { enabled = "always" },
        },
        javascript = {
          format = {
            indentSize = 2,
            tabSize = 2,
            convertTabsToSpaces = true,
          },
          tsserver = {
            maxTsServerMemory = 8192,
            nodePath = "node",
            watchOptions = {
              watchFile = "useFsEvents",
              watchDirectory = "useFsEvents",
              fallbackPolling = "dynamicPriority",
              excludeDirectories = { "**/node_modules", "**/dist", "**/.nx", "**/.git", "**/build", "**/coverage" },
            },
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
            importModuleSpecifier = "non-relative",
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

    -- Styles (Tailwind CSS v4 + React / TSX)
    vim.lsp.enable("tailwindcss")
    vim.lsp.config("tailwindcss", {
      filetypes = {
        "html", "css", "scss", "less",
        "javascriptreact", "typescriptreact",
        "vue", "svelte", "astro",
      },
      root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        -- Guard: Only attach tailwindcss if in frontend directories or frontend filetypes
        local is_frontend = fname:match("/auroras/")
          or fname:match("/apps/")
          or fname:match("%.tsx$")
          or fname:match("%.jsx$")
          or fname:match("%.html$")
          or fname:match("%.css$")
        if not is_frontend then
          return
        end
        local git_root = vim.fs.root(fname, { ".git" })
        on_dir(git_root or vim.fn.getcwd())
      end,
      settings = {
        tailwindCSS = {
          classAttributes = { "class", "className", "classList", "ngClass" },
          includeLanguages = {
            typescript = "javascript",
            typescriptreact = "javascriptreact",
          },
          experimental = {
            classRegex = {
              { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
              { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
            },
          },
        },
      },
    })

    -- HTML / CSS
    vim.lsp.enable("html")
    vim.lsp.config("html", { filetypes = { "html" } })

    vim.lsp.enable("cssls")
    vim.lsp.config("cssls", { filetypes = { "css", "scss", "less" } })

    -- Data / Config
    vim.lsp.enable("jsonls")
    vim.lsp.config("jsonls", {
      filetypes = { "json", "jsonc" },
      settings = {
        json = {
          schemas = pcall(require, "schemastore") and require("schemastore").json.schemas() or {},
          validate = { enable = true },
        },
      },
    })

    vim.lsp.enable("yamlls")
    vim.lsp.config("yamlls", {
      filetypes = { "yaml" },
      settings = {
        yaml = {
          schemaStore = {
            enable = false,
            url = "",
          },
          schemas = pcall(require, "schemastore") and require("schemastore").yaml.schemas() or {},
        },
      },
    })
    -- Linting (oxlint, ESLint) is not run in the editor on purpose: type-aware oxlint on a large
    -- monorepo lags behind typing. Lint from the shell (`bun run lint`) or let the git hook do it.
  end,
}
