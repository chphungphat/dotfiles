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

    local workspaceEnvFolder = os.getenv("WORKSPACE_ENV") or (os.getenv("HOME") .. "/Workspace/env")

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

    opts.servers.jdtls = {
      cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xms1g",
        "-Xmx2g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        vim.fn.glob(workspaceEnvFolder .. "/jdtls/latest/plugins/org.eclipse.equinox.launcher_*.jar"),
        "-configuration",
        workspaceEnvFolder .. "/jdtls/latest/config_linux",
        "-data",
        workspaceEnvFolder .. "/jdtls/workspaces/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
      },
      root_dir = function(fname)
        return require("lspconfig.util").root_pattern(
          "build.xml",
          "pom.xml",
          ".gradlew",
          ".gitignore",
          "mvnw",
          "build.gradle",
          "build.gradle.kts",
          "settings.gradle",
          "settings.gradle.kts"
        )(fname)
      end,
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
            enabled = true,
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
          progressReportProvider = true,
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
    }

    return opts
  end,

  keys = {
    { "<leader>jo", "<Cmd>lua require('jdtls').organize_imports()<CR>", desc = "Organize Imports", ft = "java" },
    {
      "<leader>jv",
      "<Cmd>lua require('jdtls').extract_variable()<CR>",
      desc = "Extract Variable",
      ft = "java",
      mode = "n",
    },
    {
      "<leader>jv",
      "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
      desc = "Extract Variable",
      ft = "java",
      mode = "v",
    },
    {
      "<leader>jc",
      "<Cmd>lua require('jdtls').extract_constant()<CR>",
      desc = "Extract Constant",
      ft = "java",
      mode = "n",
    },
    {
      "<leader>jc",
      "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
      desc = "Extract Constant",
      ft = "java",
      mode = "v",
    },
    {
      "<leader>jm",
      "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
      desc = "Extract Method",
      ft = "java",
      mode = "v",
    },
    {
      "<leader>ju",
      "<Cmd>lua require('jdtls').update_project_config()<CR>",
      desc = "Update Project Config",
      ft = "java",
    },
    { "<leader>jt", "<Cmd>lua require('jdtls').test_class()<CR>", desc = "Test Class", ft = "java" },
    { "<leader>jn", "<Cmd>lua require('jdtls').test_nearest_method()<CR>", desc = "Test Nearest Method", ft = "java" },
  },
}
