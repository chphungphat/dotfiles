vim.filetype.add({
  extension = {
    cshtml = "razor",
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = "sh",
  },
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    -- vim.highlight.on_yank()
    vim.hl.on_yank()
  end,
})

local cursorline_group = vim.api.nvim_create_augroup("CursorLineManagement", { clear = true })

local excluded_filetypes = {
  "snacks_picker", "snacks_picker_list", "snacks_picker_preview",
  "NvimTree", "NeogitStatus", "lazy", "mason",
  "help", "terminal", "prompt", "nofile"
}

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = cursorline_group,
  callback = function()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype

    if vim.tbl_contains(excluded_filetypes, ft) or vim.tbl_contains(excluded_filetypes, bt) then
      vim.wo.cursorline = false
    else
      vim.wo.cursorline = true
    end
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = cursorline_group,
  callback = function()
    vim.wo.cursorline = false
  end,
})

vim.o.background = "dark"

vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = "●",
    source = "if_many",
    format = function(diagnostic)
      local severity_icons = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = " ",
      }
      local icon = severity_icons[diagnostic.severity] or "●"
      return string.format("%s %s", icon, diagnostic.message)
    end,
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
    format = function(diagnostic)
      local source = diagnostic.source or "unknown"
      return string.format("[%s] %s", source, diagnostic.message)
    end,
  },
})
