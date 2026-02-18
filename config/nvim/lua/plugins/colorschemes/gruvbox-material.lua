return {
  "sainnhe/gruvbox-material",
  lazy = false,
  priority = 1000,
  config = function()
    -- Palette: "material" (soft), "mix" (balanced), "original" (classic gruvbox)
    vim.g.gruvbox_material_foreground = "mix"
    -- Background contrast: "hard", "medium", "soft"
    vim.g.gruvbox_material_background = "medium"

    -- Typography
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_disable_italic_comment = 0
    vim.g.gruvbox_material_enable_bold = 1

    -- UI enhancements
    vim.g.gruvbox_material_ui_contrast = "high"
    vim.g.gruvbox_material_float_style = "dim"
    vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
    vim.g.gruvbox_material_inlay_hints_background = "dimmed"
    vim.g.gruvbox_material_current_word = "grey background"

    -- Performance optimization
    vim.g.gruvbox_material_better_performance = 1

    vim.cmd.colorscheme("gruvbox-material")
  end,
}
