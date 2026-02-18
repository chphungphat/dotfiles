return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- nvim-treesitter does not support lazy-loading
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- Install parsers
      require("nvim-treesitter").install({
        -- Core web/scripting languages
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "scss",
        -- Systems/compiled languages
        "bash",
        "c",
        "c_sharp",
        "java",
        "python",
        "go",
        "rust",
        -- Config/data formats
        "json",
        "yaml",
        "toml",
        "sql",
        "dockerfile",
        -- Neovim/docs
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "vim",
        "vimdoc",
        "query",
      })

      -- Configure folding
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.opt.foldcolumn = "0"
      vim.opt.foldtext = ""
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true

      -- Enable treesitter features via autocommands
      local treesitter_group = vim.api.nvim_create_augroup("TreesitterFeatures", { clear = true })

      -- Enable highlighting for supported filetypes
      vim.api.nvim_create_autocmd("FileType", {
        group = treesitter_group,
        pattern = {
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          "scss",
          "bash",
          "c",
          "cs",
          "java",
          "python",
          "go",
          "rust",
          "json",
          "yaml",
          "toml",
          "sql",
          "dockerfile",
          "lua",
          "markdown",
          "vim",
        },
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          local filename = vim.api.nvim_buf_get_name(buf)

          -- Check file size
          if filename ~= "" then
            local ok, stats = pcall(vim.uv.fs_stat, filename)
            if ok and stats then
              -- Disable for files larger than 100KB
              if stats.size > 100 * 1024 then
                return
              end
            end
          end

          -- Enable treesitter highlighting
          vim.treesitter.start()

          -- Enable treesitter folding
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
        end,
      })

      -- Optimize for large files
      vim.api.nvim_create_autocmd("BufReadPre", {
        group = treesitter_group,
        callback = function(event)
          local buf = event.buf
          local filename = vim.api.nvim_buf_get_name(buf)

          if filename == "" then
            return
          end

          local ok, stats = pcall(vim.uv.fs_stat, filename)
          if ok and stats and stats.size > 1024 * 1024 then -- 1MB
            -- Disable expensive features for large files
            vim.bo[buf].swapfile = false
            vim.bo[buf].undofile = false
            vim.wo.foldenable = false

            if stats.size > 5 * 1024 * 1024 then -- 5MB
              -- Stop treesitter for very large files
              pcall(vim.treesitter.stop, buf)
            end
          end
        end,
      })

      -- Incremental selection configuration
      vim.keymap.set("n", "<M-Up>", function()
        vim.cmd("normal! v")
        local ts_utils = require("nvim-treesitter.ts_utils")
        local node = ts_utils.get_node_at_cursor()
        if node then
          node = node:parent()
          if node then
            ts_utils.update_selection(0, node)
          end
        end
      end, { desc = "Increment selection to parent node" })

      vim.keymap.set("v", "<M-Up>", function()
        local ts_utils = require("nvim-treesitter.ts_utils")
        local node = ts_utils.get_node_at_cursor()
        if node then
          node = node:parent()
          if node then
            ts_utils.update_selection(0, node)
          end
        end
      end, { desc = "Increment selection to parent node" })

      vim.keymap.set("v", "<M-Down>", function()
        local ts_utils = require("nvim-treesitter.ts_utils")
        local node = ts_utils.get_node_at_cursor()
        if node then
          local children = ts_utils.get_named_children(node)
          if #children > 0 then
            ts_utils.update_selection(0, children[1])
          end
        end
      end, { desc = "Decrement selection to child node" })

      -- Setup nvim-treesitter-textobjects
      local ts_textobjects_ok, ts_textobjects = pcall(require, "nvim-treesitter-textobjects")
      if ts_textobjects_ok then
        ts_textobjects.setup({
          select = {
            lookahead = true,
            include_surrounding_whitespace = false,
          },
          move = {
            set_jumps = true,
          },
        })

        -- Text object selection keymaps
        vim.keymap.set({ "x", "o" }, "af", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
        end, { desc = "Select outer function" })

        vim.keymap.set({ "x", "o" }, "if", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
        end, { desc = "Select inner function" })

        vim.keymap.set({ "x", "o" }, "ac", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
        end, { desc = "Select outer class" })

        vim.keymap.set({ "x", "o" }, "ic", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
        end, { desc = "Select inner class" })

        vim.keymap.set({ "x", "o" }, "aa", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
        end, { desc = "Select outer parameter" })

        vim.keymap.set({ "x", "o" }, "ia", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
        end, { desc = "Select inner parameter" })

        vim.keymap.set({ "x", "o" }, "ai", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer", "textobjects")
        end, { desc = "Select outer conditional" })

        vim.keymap.set({ "x", "o" }, "ii", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
        end, { desc = "Select inner conditional" })

        vim.keymap.set({ "x", "o" }, "al", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer", "textobjects")
        end, { desc = "Select outer loop" })

        vim.keymap.set({ "x", "o" }, "il", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner", "textobjects")
        end, { desc = "Select inner loop" })

        -- Navigation keymaps
        vim.keymap.set("n", "]f", function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
        end, { desc = "Next function start" })

        vim.keymap.set("n", "[f", function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
        end, { desc = "Previous function start" })

        vim.keymap.set("n", "]c", function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
        end, { desc = "Next class start" })

        vim.keymap.set("n", "[c", function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
        end, { desc = "Previous class start" })

        vim.keymap.set("n", "]a", function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner", "textobjects")
        end, { desc = "Next parameter" })

        vim.keymap.set("n", "[a", function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.inner", "textobjects")
        end, { desc = "Previous parameter" })
      end
    end,
  },
}
