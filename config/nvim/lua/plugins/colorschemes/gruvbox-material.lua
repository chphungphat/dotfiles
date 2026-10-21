return {
  "sainnhe/gruvbox-material",
  priority = 1000,
  lazy = false,
  config = function()
    -- Contrast: "hard", "medium", "soft"
    vim.g.gruvbox_material_background = "medium"
    -- Palette: "material" (softer, low-saturation earth tones, minimizes distraction)
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_enable_italic = true
    vim.g.gruvbox_material_better_performance = 1
    vim.g.gruvbox_material_dim_inactive_windows = 1
    vim.g.gruvbox_material_ui_contrast = "low"
    vim.g.gruvbox_material_diagnostic_virtual_text = "colored"

    vim.o.background = "dark"
    vim.cmd.colorscheme("gruvbox-material")
  end,
}
