return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>ff",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = { "n", "v" },
      desc = "Format buffer or selection",
    },
  },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },

        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },

        -- Python
        python = { "isort", "black" },

        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },

        -- C/C++
        c = { "clang_format" },
        cpp = { "clang_format" },
        objc = { "clang_format" },
        objcpp = { "clang_format" },

        -- C#
        cs = { "csharpier" },
      },

      -- Smart format on save - only when formatters are available
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat then
          return
        end

        -- Skip filetypes with no formatter configured (avoids broken LSP fallback)
        local ft = vim.bo[bufnr].filetype
        local no_format_fts = { kotlin = true, groovy = true, java = true }
        if no_format_fts[ft] then
          return
        end

        -- Skip for large files (>1MB)
        local max_filesize = 1024 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size and stats.size > max_filesize then
          return
        end

        -- Skip for readonly files
        if vim.bo[bufnr].readonly then
          return
        end

        -- Skip for certain paths
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local ignore_patterns = { "node_modules", "%.git/", "vendor/", "target/", "build/" }
        for _, pattern in ipairs(ignore_patterns) do
          if bufname:match(pattern) then
            return
          end
        end

        return {
          timeout_ms = 1000,
          lsp_fallback = true,
          quiet = true,
        }
      end,

      formatters = {
        prettier = {
          command = "prettier",
          condition = function(_, ctx)
            local prettier_files = {
              ".prettierrc", ".prettierrc.json", ".prettierrc.js",
              ".prettierrc.yml", ".prettierrc.yaml", "prettier.config.js",
              "prettier.config.mjs", "prettier.config.cjs",
            }

            -- Walk up the directory tree to find prettier config
            local found = vim.fs.find(prettier_files, {
              path = ctx.dirname,
              upward = true,
              stop = vim.uv.os_homedir(),
            })
            if #found > 0 then
              return true
            end

            -- Check for "prettier" key in nearest package.json
            local pkg = vim.fs.find("package.json", {
              path = ctx.dirname,
              upward = true,
              stop = vim.uv.os_homedir(),
            })
            if #pkg > 0 then
              local ok, content = pcall(vim.fn.readfile, pkg[1])
              if ok and content then
                return table.concat(content, "\n"):match('"prettier"') ~= nil
              end
            end

            return false
          end,
        },

        stylua = {
          condition = function(_, ctx)
            return #vim.fs.find({ "stylua.toml", ".stylua.toml" }, {
              path = ctx.dirname,
              upward = true,
              stop = vim.uv.os_homedir(),
            }) > 0
          end,
        },

        shfmt = {
          prepend_args = { "-i", "2", "-ci" },
        },

        clang_format = {
          condition = function(_, ctx)
            local cwd = vim.fs.dirname(ctx.filename)
            return vim.uv.fs_stat(cwd .. "/.clang-format") ~= nil or
                vim.uv.fs_stat(cwd .. "/_clang-format") ~= nil or
                vim.uv.fs_stat(vim.fn.getcwd() .. "/.clang-format") ~= nil
          end,
          args = { "--style=file" }, -- Use .clang-format file in project
        },
      },

      format_after_save = nil,

      notify_on_error = true,
      notify_no_formatters = false,
    })

    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      require("conform").format({ async = true, lsp_fallback = true, range = range })
    end, { range = true, desc = "Format buffer or range" })

    vim.api.nvim_create_user_command("FormatToggle", function()
      if vim.g.disable_autoformat then
        vim.g.disable_autoformat = false
        vim.notify("Format on save enabled", vim.log.levels.INFO)
      else
        vim.g.disable_autoformat = true
        vim.notify("Format on save disabled", vim.log.levels.WARN)
      end
    end, { desc = "Toggle format on save" })
  end,
}
