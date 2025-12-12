return {
  "sontungexpt/stcursorword",
  event = "VeryLazy",
  config = function()
    require("stcursorword").setup({
      excluded = {
        filetypes = {
          "TelescopePrompt",
          "oil_preview",
          "copilot-chat",
          "oil",
          "snacks_picker",
          "snacks_picker_list",
          "snacks_picker_preview",
          "neo-tree",
          "neo-tree-popup",
          "NeogitStatus",
        },
      },
    })
  end,
}
