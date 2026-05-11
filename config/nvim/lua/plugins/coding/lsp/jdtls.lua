return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  config = function()
    local jdtlsPath = os.getenv("HOME") .. "/.local/share/jdtls"
    local jdtlsDataDir = os.getenv("HOME") .. "/.local/share/jdtls-workspaces"

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

    local lombok_jar = vim.fn.glob(jdtlsPath .. "/plugins/lombok*.jar")
    local launcher_jar = vim.fn.glob(jdtlsPath .. "/plugins/org.eclipse.equinox.launcher_*.jar")

    if lombok_jar == "" or launcher_jar == "" then
      vim.notify("jdtls not properly configured. Missing jars at: " .. jdtlsPath, vim.log.levels.WARN)
      return
    end

    local workspaceDir = jdtlsDataDir .. "/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

    local function make_config()
      return {
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
          workspaceDir,
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
            autobuild = { enabled = false },
            maxConcurrentBuilds = 2,
            eclipse = { downloadSources = false },
            maven = { downloadSources = false },
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
            implementationsCodeLens = { enabled = false },
            referencesCodeLens = { enabled = false },
            references = { includeDecompiledSources = true },
            format = {
              enabled = false,
              settings = {
                url = "",
                profile = "Default",
              },
              insertSpaces = vim.bo.expandtab,
              tabSize = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or 2,
            },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
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
              importOrder = { "#", "", "java", "javax" },
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
              hashCodeEquals = { useJava7Objects = true },
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
              nullAnalysis = { mode = "automatic" },
            },
          },
        },
        init_options = {
          bundles = {},
          extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
        },
      }
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      group = vim.api.nvim_create_augroup("JdtlsSetup", { clear = true }),
      callback = function()
        require("jdtls").start_or_attach(make_config())
      end,
    })

    require("jdtls").start_or_attach(make_config())

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("JdtlsAttach", { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client or client.name ~= "jdtls" then return end

        local bufnr = event.buf
        local opts = { buffer = bufnr, noremap = true, silent = true }

        vim.api.nvim_buf_create_user_command(bufnr, "JdtWipeWorkspace", function()
          local ok = vim.fn.confirm("Wipe jdtls workspace at:\n" .. workspaceDir, "&Yes\n&No", 2)
          if ok ~= 1 then return end
          for _, c in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
            c:stop()
          end
          vim.fn.delete(workspaceDir, "rf")
          vim.defer_fn(function() vim.cmd("edit") end, 500)
        end, { desc = "Wipe jdtls workspace and restart" })

        vim.keymap.set("n", "<leader>jo", "<Cmd>lua require('jdtls').organize_imports()<CR>", opts)
        vim.keymap.set("n", "<leader>jv", "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
        vim.keymap.set("v", "<leader>jv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)
        vim.keymap.set("n", "<leader>jc", "<Cmd>lua require('jdtls').extract_constant()<CR>", opts)
        vim.keymap.set("v", "<leader>jc", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", opts)
        vim.keymap.set("v", "<leader>jm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)
        vim.keymap.set(
          "n", "<leader>ju", "<Cmd>JdtWipeWorkspace<CR>",
          vim.tbl_extend("force", opts, { desc = "Wipe workspace and restart" })
        )
        vim.keymap.set("n", "<leader>jt", "<Cmd>lua require('jdtls').test_class()<CR>", opts)
        vim.keymap.set("n", "<leader>jn", "<Cmd>lua require('jdtls').test_nearest_method()<CR>", opts)
        vim.keymap.set(
          "n", "<leader>js", "<Cmd>lua require('jdtls').super_implementation()<CR>",
          vim.tbl_extend("force", opts, { desc = "Go to super implementation" })
        )
        vim.keymap.set(
          "n", "<leader>jb", "<Cmd>JdtBytecode<CR>",
          vim.tbl_extend("force", opts, { desc = "View bytecode (helps understand performance/JVM behavior)" })
        )
        vim.keymap.set(
          "n", "<leader>jh", "<Cmd>JdtJshell<CR>",
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
          require("jdtls").setup_dap({ hotcodereplace = "auto" })
          require("jdtls.dap").setup_dap_main_class_configs()
        end
      end,
    })
  end,
}
