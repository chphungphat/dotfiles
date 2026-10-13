-- Kept as reference. Replaced by oasis.nvim (see oasis.lua).
-- To restore: delete this line and the next, then uncomment the block below.
-- return {}

return {
  "ThorstenRhau/token",
  priority = 1000,
  lazy = false,
  config = function()
    require('token').setup({
      dim_inactive = true,
      plugins = {
        all = true
      },

      on_highlights = function(highlights, colors)
        highlights.GitSignsCurrentLineBlame = { fg = colors.fg2, italic = true }
        highlights.SnacksPickerDir = { fg = colors.fg2 }
        highlights.SnacksPickerPathHidden = { fg = colors.fg2 }
        highlights.SnacksPickerPathIgnored = { fg = colors.fg2 }
      end,
    })
    vim.o.background = "dark"
    vim.cmd.colorscheme("token-meridian")
  end,
}
