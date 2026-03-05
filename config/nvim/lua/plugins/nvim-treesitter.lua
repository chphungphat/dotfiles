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

        "astro"
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

      -- Incremental selection configuration (native vim.treesitter API)
      local function select_node_range(node)
        local sr, sc, er, ec = node:range()
        vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
        vim.cmd("normal! v")
        vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
      end

      local function get_covering_node(sr, sc, er, ec)
        local node = vim.treesitter.get_node({ pos = { sr, sc } })
        while node do
          local nr, nc, ner, nec = node:range()
          if nr <= sr and nc <= sc and (ner > er or (ner == er and nec >= ec)) then
            return node
          end
          node = node:parent()
        end
      end

      vim.keymap.set("n", "<M-Up>", function()
        local node = vim.treesitter.get_node()
        if not node then return end
        local parent = node:parent()
        if not parent then return end
        select_node_range(parent)
      end, { desc = "Increment selection to parent node" })

      vim.keymap.set("v", "<M-Up>", function()
        local vstart = vim.fn.getpos("v")
        local vcur = vim.fn.getpos(".")
        local sr = math.min(vstart[2], vcur[2]) - 1
        local sc = math.min(vstart[3], vcur[3]) - 1
        local er = math.max(vstart[2], vcur[2]) - 1
        local ec = math.max(vstart[3], vcur[3])
        local covering = get_covering_node(sr, sc, er, ec)
        local parent = covering and covering:parent()
        if not parent then return end
        local psr, psc, per, pec = parent:range()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        vim.schedule(function()
          vim.api.nvim_win_set_cursor(0, { psr + 1, psc })
          vim.cmd("normal! v")
          vim.api.nvim_win_set_cursor(0, { per + 1, math.max(pec - 1, 0) })
        end)
      end, { desc = "Increment selection to parent node" })

      vim.keymap.set("v", "<M-Down>", function()
        local vstart = vim.fn.getpos("v")
        local vcur = vim.fn.getpos(".")
        local sr = math.min(vstart[2], vcur[2]) - 1
        local sc = math.min(vstart[3], vcur[3]) - 1
        local er = math.max(vstart[2], vcur[2]) - 1
        local ec = math.max(vstart[3], vcur[3])
        local covering = get_covering_node(sr, sc, er, ec)
        if not covering then return end
        local child = covering:named_child(0)
        if not child then return end
        local csr, csc, cer, cec = child:range()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        vim.schedule(function()
          vim.api.nvim_win_set_cursor(0, { csr + 1, csc })
          vim.cmd("normal! v")
          vim.api.nvim_win_set_cursor(0, { cer + 1, math.max(cec - 1, 0) })
        end)
      end, { desc = "Decrement selection to child node" })

      -- <C-space> incremental selection (replaces old nvim-treesitter.configs incremental_selection)
      -- First press: select the node at cursor (e.g. just "method" in "text.method()")
      -- Subsequent presses in visual mode: expand to parent (e.g. "text.method()")
      vim.keymap.set("n", "<C-space>", function()
        local node = vim.treesitter.get_node()
        if not node then return end
        select_node_range(node)
      end, { desc = "Select current treesitter node" })

      vim.keymap.set("v", "<C-space>", function()
        local vstart = vim.fn.getpos("v")
        local vcur = vim.fn.getpos(".")
        local sr = math.min(vstart[2], vcur[2]) - 1
        local sc = math.min(vstart[3], vcur[3]) - 1
        local er = math.max(vstart[2], vcur[2]) - 1
        local ec = math.max(vstart[3], vcur[3])
        local covering = get_covering_node(sr, sc, er, ec)
        local parent = covering and covering:parent()
        if not parent then return end
        local psr, psc, per, pec = parent:range()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        vim.schedule(function()
          vim.api.nvim_win_set_cursor(0, { psr + 1, psc })
          vim.cmd("normal! v")
          vim.api.nvim_win_set_cursor(0, { per + 1, math.max(pec - 1, 0) })
        end)
      end, { desc = "Expand selection to parent node" })

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
