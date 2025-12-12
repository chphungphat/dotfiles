vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set({ "n", "i", "v" }, "<F1>", "<nop>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>-", "<C-w>s", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>\\", "<C-w>v", { desc = "Split vertical" })

vim.keymap.set("n", "<ESC>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostic Error messages" })
vim.keymap.set("n", "<leader>ca", vim.diagnostic.setloclist, { desc = "Open diagnostic Quickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>hh", ":tab help<Space>", { desc = "Tab help" })

vim.keymap.set("n", "<leader>cD", function()
  vim.diagnostic.setqflist({
    severity = {
      vim.diagnostic.severity.ERROR,
      vim.diagnostic.severity.WARN
    }
  })
end, { desc = "Show all diagnostics in quickfix" })

vim.keymap.set("n", "<leader>cw", function()
  vim.diagnostic.setqflist({
    severity = vim.diagnostic.severity.WARN
  })
end, { desc = "Show warnings in quickfix" })

vim.keymap.set("n", "<leader>ce", function()
  vim.diagnostic.setqflist({
    severity = vim.diagnostic.severity.ERROR
  })
end, { desc = "Show errors in quickfix" })

-- Toggle diagnostic virtual text
vim.keymap.set("n", "<leader>cv", function()
  local current_config = vim.diagnostic.config()
  vim.diagnostic.config({
    virtual_text = not current_config.virtual_text
  })
  local status = current_config.virtual_text and "disabled" or "enabled"
  vim.notify("Diagnostic virtual text " .. status, vim.log.levels.INFO)
end, { desc = "Toggle diagnostic virtual text" })
