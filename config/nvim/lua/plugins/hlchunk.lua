return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({
      indent = {
        enable = true,
        chars = { "│" },
        exclude_filetypes = {
          "help",
          "terminal",
          "lazy",
          "mason",
          "snacks_picker",
          "snacks_picker_list",
          "snacks_picker_preview",
          "neo-tree",
          "TelescopePrompt",
          "oil",
          "notify",
        },
      },

      chunk = {
        enable = false,
        chars = {
          horizontal_line = "─",
          vertical_line = "│",
          left_top = "┌",
          left_bottom = "└",
          right_arrow = "─",
        },
        duration = 200,
        delay = 300,
      },
    })
  end,
}
