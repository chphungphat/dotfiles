return {
  "nvim-tree/nvim-tree.lua",
  event = "VimEnter",
  config = function()
    require("nvim-tree").setup({
      sort = { sorter = "case_sensitive" },
      view = { width = 30 },
      renderer = {
        group_empty = true,
        highlight_git = "name",
        highlight_diagnostics = "name",
        icons = {
          git_placement = "before",
          show = {
            git = false,
            diagnostics = false,
          },
        },
      },
      filters = { dotfiles = false, git_ignored = false },
      git = { enable = true },
      diagnostics = { enable = true },
      actions = {
        open_file = { quit_on_open = false },
      },
    })

    -- LSP diagnostic filenames: use color + underline instead of icons
    local function set_diagnostic_highlights()
      local err = vim.api.nvim_get_hl(0, { name = "DiagnosticError", link = false })
      local warn = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn", link = false })
      vim.api.nvim_set_hl(0, "NvimTreeDiagnosticErrorFileHL", { fg = err.fg, sp = err.fg, underline = true })
      vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarnFileHL", { fg = warn.fg, sp = warn.fg, underline = true })
    end

    set_diagnostic_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_diagnostic_highlights })

    vim.schedule(function()
      require("nvim-tree.api").tree.open()
    end)
  end,
  keys = {
    { "<leader>ee", function() require("nvim-tree.api").tree.toggle() end, desc = "Toggle Explorer" },
    { "<leader>ef", function() require("nvim-tree.api").tree.focus() end,  desc = "Focus Explorer" },
  },
}
