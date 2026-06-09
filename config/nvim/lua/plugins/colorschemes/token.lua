-- return {}
return {
  "ThorstenRhau/token",
  priority = 1000,
  lazy = false,
  config = function()
    vim.o.background = "dark"
    vim.cmd.colorscheme("token")
  end,
}
