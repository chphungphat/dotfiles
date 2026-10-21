local function toggle_diffview()
  local lib = require("diffview.lib")
  if lib.get_current_view() or #lib.views > 0 then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
  end
end

local function toggle_file_history()
  local lib = require("diffview.lib")
  if lib.get_current_view() or #lib.views > 0 then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewFileHistory %")
  end
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", toggle_diffview, desc = "Toggle Git Diffview" },
    { "<leader>gh", toggle_file_history, desc = "Toggle Git File History (%)" },
  },
  opts = function()
    local actions = require("diffview.actions")
    return {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
        },
      },
      keymaps = {
        view = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
          { "n", "<c-d>", actions.scroll_view(0.25), { desc = "Scroll diff view down" } },
          { "n", "<c-u>", actions.scroll_view(-0.25), { desc = "Scroll diff view up" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
          { "n", "<c-d>", actions.scroll_view(0.25), { desc = "Scroll diff view down" } },
          { "n", "<c-u>", actions.scroll_view(-0.25), { desc = "Scroll diff view up" } },
        },
      },
    }
  end,
}
