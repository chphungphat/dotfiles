return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mfussenegger/nvim-jdtls",
    "Hoffs/omnisharp-extended-lsp.nvim",
  },
  config = function()
    local jdtlsPath = os.getenv("HOME") .. "/.local/share/jdtls"
    local jdtlsDataDir = os.getenv("HOME") .. "/.local/share/jdtls-workspaces"

    -- Get Java home and version dynamically (sdkman)
    local javaHome = os.getenv("JAVA_HOME")
    local javaVersion = nil
    if javaHome then
      local handle = io.popen("java -version 2>&1")
      if handle then
        local result = handle:read("*a")
        handle:close()
        javaVersion = result:match('version "(%d+)')
      end
    end

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
        vim.keymap.set("n", "gD",
          vim.lsp.buf.declaration,
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

        vim.keymap.set({ "n", "v" }, "<leader>ca",
          vim.lsp.buf.code_action,
          vim.tbl_extend("force", opts, { desc = "Code actions" }))
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
            local params = {
              command = "_typescript.organizeImports",
              arguments = { vim.api.nvim_buf_get_name(0) },
              title = "Organize Imports",
            }
            vim.lsp.buf_request(0, "workspace/executeCommand", params)
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

    -- jdtls
    local lombok_jar = vim.fn.glob(jdtlsPath .. "/plugins/lombok*.jar")
    local launcher_jar = vim.fn.glob(jdtlsPath .. "/plugins/org.eclipse.equinox.launcher_*.jar")

    if lombok_jar == "" or launcher_jar == "" then
      vim.notify(
        "jdtls not properly configured. Missing jars at: ",
        vim.log.levels.WARN
      )
    else
      vim.lsp.enable("jdtls")
      vim.lsp.config("jdtls", {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=false",
          "-Dlog.level=ERROR",
          "-Xms2g",
          "-Xmx8g",
          "-XX:+UseG1GC",
          "-XX:+UseStringDeduplication",
          "-XX:ConcGCThreads=4",
          "-XX:ParallelGCThreads=8",
          "-Dsun.zip.disableMemoryMapping=true",
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
          "-javaagent:" .. lombok_jar,
          "-jar",
          launcher_jar,
          "-configuration",
          jdtlsPath .. "/config_linux",
          "-data",
          jdtlsDataDir .. "/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
        },
        root_dir = vim.fs.dirname(vim.fs.find({
          "build.xml",
          "pom.xml",
          ".gradlew",
          ".gitignore",
          "mvnw",
          "build.gradle",
          "build.gradle.kts",
          "settings.gradle",
          "settings.gradle.kts",
        }, { upward = true })[1]),
        settings = {
          java = {
            -- inlayHints = {
            --   parameterNames = {
            --     enabled = "all",
            --   },
            -- },
            autobuild = {
              enabled = false, -- Disable autobuild for faster saves
            },
            maxConcurrentBuilds = 2,
            eclipse = {
              downloadSources = false, -- Lazy load to speed up import
            },
            maven = {
              downloadSources = false,
            },
            import = {
              generatesMetadataFilesAtProjectRoot = false,
              exclusions = {
                "**/build/**",
                "**/bin/**",
                "**/out/**",
                "**/.gradle/**",
                "**/node_modules/**",
                "**/.metadata/**",
                "**/archetype-resources/**",
                "**/META-INF/maven/**",
              },
              gradle = {
                wrapper = {
                  checksums = {
                    {
                      sha256 = "e68185c8c0f67873dcd98916621870266a71584dfb0a2861d87d7077ebc39837",
                      allowed = true,
                    },
                  },
                },
              },
            },
            implementationsCodeLens = {
              enabled = false,
            },
            referencesCodeLens = {
              enabled = false,
            },
            references = {
              includeDecompiledSources = true,
            },
            format = {
              enabled = false,
              -- Use project settings (.editorconfig) instead of Google style
              settings = {
                url = "",            -- Empty URL = respect project's editorconfig
                profile = "Default", -- Use default profile
              },
              -- Sync with Neovim's buffer settings dynamically
              insertSpaces = vim.bo.expandtab,                            -- Use spaces if expandtab is set
              tabSize = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or 2, -- Respect shiftwidth
            },
            signatureHelp = {
              enabled = true,
            },
            contentProvider = {
              preferred = "fernflower",
            },
            completion = {
              favoriteStaticMembers = {
                "org.hamcrest.MatcherAssert.assertThat",
                "org.hamcrest.Matchers.*",
                "org.hamcrest.CoreMatchers.*",
                "org.junit.jupiter.api.Assertions.*",
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
                "org.mockito.Mockito.*",
              },
              filteredTypes = {
                "com.sun.*",
                "io.micrometer.shaded.*",
                "java.awt.*",
                "jdk.*",
                "sun.*",
              },
              -- Import order matching Spotless: importOrder("\\#", "", "java|javax")
              -- Static imports first, then all other imports, then java/javax
              importOrder = {
                "#",     -- Static imports
                "",      -- All other imports (third-party: com, org, etc.)
                "java",  -- java packages
                "javax", -- javax packages
              },
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            codeGeneration = {
              toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
              },
              hashCodeEquals = {
                useJava7Objects = true,
              },
              useBlocks = true,
            },
            configuration = {
              runtimes = javaHome and javaVersion and {
                {
                  name = "JavaSE-" .. javaVersion,
                  path = javaHome,
                },
              } or {},
            },
            compile = {
              nullAnalysis = {
                mode = "automatic",
              },
            },
          },
        },
        init_options = {
          bundles = {},
          extendedClientCapabilities = {
            progressReportProvider = false,
            -- statusBarProvider = false,
            classFileContentsSupport = true,
            generateToStringPromptSupport = true,
            hashCodeEqualsPromptSupport = true,
            advancedExtractRefactoringSupport = true,
            advancedOrganizeImportsSupport = true,
            generateConstructorsPromptSupport = true,
            generateDelegateMethodsPromptSupport = true,
            moveRefactoringSupport = true,
            overrideMethodsPromptSupport = true,
            inferSelectionSupport = { "extractMethod", "extractVariable", "extractConstant" },
          },
        },
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.keymap.set(
            "n",
            "<leader>jo",
            "<Cmd>lua require('jdtls').organize_imports()<CR>",
            opts
          )
          vim.keymap.set(
            "n",
            "<leader>jv",
            "<Cmd>lua require('jdtls').extract_variable()<CR>",
            opts
          )
          vim.keymap.set(
            "v",
            "<leader>jv",
            "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
            opts
          )
          vim.keymap.set(
            "n",
            "<leader>jc",
            "<Cmd>lua require('jdtls').extract_constant()<CR>",
            opts
          )
          vim.keymap.set(
            "v",
            "<leader>jc",
            "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
            opts
          )
          vim.keymap.set(
            "v",
            "<leader>jm",
            "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
            opts
          )
          vim.keymap.set(
            "n",
            "<leader>ju",
            "<Cmd>JdtWipeDataAndRestart<CR>",
            vim.tbl_extend("force", opts, { desc = "Wipe workspace and restart (fixes dependency issues)" })
          )
          vim.keymap.set("n", "<leader>jt", "<Cmd>lua require('jdtls').test_class()<CR>", opts)
          vim.keymap.set(
            "n",
            "<leader>jn",
            "<Cmd>lua require('jdtls').test_nearest_method()<CR>",
            opts
          )

          vim.keymap.set(
            "n",
            "<leader>js",
            "<Cmd>lua require('jdtls').super_implementation()<CR>",
            vim.tbl_extend("force", opts, { desc = "Go to super implementation" })
          )
          vim.keymap.set(
            "n",
            "<leader>jb",
            "<Cmd>JdtBytecode<CR>",
            vim.tbl_extend("force", opts, { desc = "View bytecode (helps understand performance/JVM behavior)" })
          )
          vim.keymap.set(
            "n",
            "<leader>jh",
            "<Cmd>JdtJshell<CR>",
            vim.tbl_extend("force", opts, { desc = "Open JShell (interactive Java REPL for quick testing)" })
          )

          local dap_ok, dap = pcall(require, "dap")
          if dap_ok then
            dap.configurations.java = {
              {
                type = "java",
                request = "attach",
                name = "Debug (Attach) - Remote",
                hostName = "127.0.0.1",
                port = 5005,
              },
            }
            -- Enable hot code replacement during debugging (apply code changes without restart)
            require("jdtls").setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()
          end
        end,
      })
    end

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

    vim.lsp.enable('tinymist')
    vim.lsp.config('tinymist', {})

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

    -- OmniSharp with Extended LSP support
    -- Using Neovim 0.11+ vim.lsp.config() API to override default omnisharp config
    local omnisharp_bin = os.getenv("HOME") .. "/.local/share/omnisharp/run"
    if vim.fn.executable(omnisharp_bin) == 1 then
      -- Override the default omnisharp config from nvim-lspconfig/lsp/omnisharp.lua
      vim.lsp.config("omnisharp", {
        cmd = {
          omnisharp_bin,
          "-z", -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
          "--hostPID",
          tostring(vim.fn.getpid()),
          "DotNet:enablePackageRestore=false",
          "--encoding",
          "utf-8",
          "--languageserver",
        },
        capabilities = capabilities,
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = true,
          },
          MsBuild = {
            LoadProjectsOnDemand = true,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
            AnalyzeOpenDocumentsOnly = true,
            EnableDecompilationSupport = true,
          },
          Sdk = {
            IncludePrereleases = true,
          },
        },
        handlers = {
          ["textDocument/definition"] = function(...)
            return require("omnisharp_extended").handler(...)
          end,
          ["textDocument/typeDefinition"] = function(...)
            return require("omnisharp_extended").handler(...)
          end,
          ["textDocument/references"] = function(...)
            return require("omnisharp_extended").handler(...)
          end,
          ["textDocument/implementation"] = function(...)
            return require("omnisharp_extended").handler(...)
          end,
        },
        on_attach = function(client, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          -- C# specific keymaps
          vim.keymap.set(
            "n",
            "<leader>co",
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = {
                  only = { "source.organizeImports" },
                  diagnostics = {},
                },
              })
            end,
            vim.tbl_extend("force", opts, { desc = "Organize Imports (C#)" })
          )
        end,
      })

      vim.lsp.enable("omnisharp")
    else
      vim.notify(
        "OmniSharp not found at: " ..
        omnisharp_bin ..
        "\nInstall with: curl -sL https://github.com/OmniSharp/omnisharp-roslyn/releases/latest/download/omnisharp-linux-x64-net6.0.tar.gz | tar xz -C ~/.local/share/omnisharp",
        vim.log.levels.WARN
      )
    end
  end,
}
