return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- nvim-treesitter does not support lazy-loading
    config = function()
      -- Install parsers
      require("nvim-treesitter").install({
        "javascript", "typescript", "tsx", "bash", "c", "c_sharp", "java",
        "html", "lua", "luadoc", "markdown", "vim", "vimdoc", "query"
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
          "javascript", "typescript", "tsx", "bash", "c", "cs", "java",
          "html", "lua", "markdown", "vim", "python", "go", "rust"
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

          -- Enable experimental indentation (optional)
          -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Optimize for large files
      vim.api.nvim_create_autocmd("BufReadPre", {
        group = treesitter_group,
        callback = function(event)
          local buf = event.buf
          local filename = vim.api.nvim_buf_get_name(buf)

          if filename == "" then return end

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
    end,
  },

  -- nvim-treesitter-textobjects is temporarily disabled
  -- It doesn't yet support the new nvim-treesitter rewrite
  -- You can re-enable it once it's updated to work with the new API
  -- {
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  --   lazy = false,
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  -- },
}
