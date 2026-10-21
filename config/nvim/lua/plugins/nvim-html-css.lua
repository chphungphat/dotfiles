return {
  "Jezda1337/nvim-html-css",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = {
    "html",
    "htmldjango",
    "typescriptreact",
    "javascriptreact",
    "svelte",
    "astro",
    "vue",
  },
  opts = {
    enable_on = {
      "html",
      "htmldjango",
      "typescriptreact",
      "javascriptreact",
      "svelte",
      "astro",
      "vue",
    },
    style_sheets = {
      "./auroras/kits/ui/src/styles/core/utilities.css",
      "./auroras/kits/ui/src/styles/core/spinner.css",
      "./auroras/kits/ui/src/styles/core/base.css",
      "./auroras/kits/ui/src/styles/core/tailwind.css",
    },
  },
}
