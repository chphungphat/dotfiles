return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local workspaceEnvFolder = os.getenv("WORKSPACE_ENV")
    if workspaceEnvFolder == nil or workspaceEnvFolder == "" then
      local possiblePaths = {
        os.getenv("HOME") .. "/Workspaces/.env",
        os.getenv("HOME") .. "/Workspaces/environment",
        os.getenv("HOME") .. "/.local/share/jdtls",
      }
      for _, path in ipairs(possiblePaths) do
        if vim.fn.isdirectory(path .. "/jdtls") == 1 then
          workspaceEnvFolder = path
          break
        end
      end
      if workspaceEnvFolder == nil then
        workspaceEnvFolder = os.getenv("HOME") .. "/Workspaces/.env"
      end
    end

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
          require("snacks").picker.lsp_definitions()
        end, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD", function()
          require("snacks").picker.lsp_declarations()
        end, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gr", function()
          require("snacks").picker.lsp_references()
        end, vim.tbl_extend("force", opts, { desc = "Show references" }))
        vim.keymap.set("n", "gi", function()
          require("snacks").picker.lsp_implementations()
        end, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "gt", function()
          require("snacks").picker.lsp_type_definitions()
        end, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))

        vim.keymap.set("n", "<leader>cs", function()
          require("snacks").picker.lsp_symbols()
        end, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
        vim.keymap.set("n", "<leader>cS", function()
          require("snacks").picker.lsp_workspace_symbols()
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

    vim.diagnostic.config({
      virtual_text = {
        spacing = 4,
        prefix = "●",
        source = "if_many",
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.INFO] = "",
          [vim.diagnostic.severity.HINT] = "",
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
      },
    })

    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    vim.lsp.enable("lua_ls")
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
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
            includeInlayParameterNameHints = "literal",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayVariableTypeHints = false,
            includeInlayPropertyDeclarationTypeHints = false,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayEnumMemberValueHints = false,
          },
        },
      },
    })

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
    -- Get jdtls jar paths
    local lombok_jar = vim.fn.glob(workspaceEnvFolder .. "/jdtls/latest/plugins/lombok*.jar")
    local launcher_jar =
        vim.fn.glob(workspaceEnvFolder .. "/jdtls/latest/plugins/org.eclipse.equinox.launcher_*.jar")

    if lombok_jar == "" or launcher_jar == "" then
      vim.notify(
        "jdtls not properly configured. Missing jars at: "
        .. workspaceEnvFolder
        .. "/jdtls/latest/plugins/",
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
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xms2g",
          "-Xmx8g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
          "-javaagent:" .. lombok_jar,
          "-jar",
          launcher_jar,
          "-configuration",
          workspaceEnvFolder .. "/jdtls/latest/config_linux",
          "-data",
          workspaceEnvFolder
          .. "/jdtls/workspaces/"
          .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
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
            eclipse = {
              downloadSources = true,
            },
            maven = {
              downloadSources = true,
            },
            imports = {
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
            referencesCodeLens = {
              enabled = false, -- Disabled for performance on large codebases
            },
            references = {
              includeDecompiledSources = true,
            },
            format = {
              enabled = true,
              settings = {
                url = vim.fn.stdpath("config") .. "/resources/intellij-java-google-style.xml",
                profile = "GoogleStyle",
              },
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
              importOrder = {
                "java",
                "javax",
                "com",
                "org",
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
          },
        },
        init_options = {
          bundles = {},
          extendedClientCapabilities = {
            progressReportProvider = false,
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
            "<Cmd>lua require('jdtls').update_project_config()<CR>",
            opts
          )
          vim.keymap.set("n", "<leader>jt", "<Cmd>lua require('jdtls').test_class()<CR>", opts)
          vim.keymap.set(
            "n",
            "<leader>jn",
            "<Cmd>lua require('jdtls').test_nearest_method()<CR>",
            opts
          )
        end,
      })
    end

    vim.lsp.enable("eslint")
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
  end,
}
