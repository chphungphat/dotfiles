return {
	"brenoprata10/nvim-highlight-colors",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("nvim-highlight-colors").setup({
			render = "background",
			virtual_symbol = "■",
			enable_hex = true,
			enable_short_hex = true,
			enable_rgb = true,
			enable_hsl = true,
			enable_var_usage = true,
			enable_named_colors = true,
			enable_tailwind = false,

			---Set custom colors
			---Label must be properly escaped with '%' to adhere to `string.gmatch`
			--- :help string.gmatch
			custom_colors = {
				{ label = "%-%-theme%-primary%-color", color = "#0f1219" },
				{ label = "%-%-theme%-secondary%-color", color = "#5a5d64" },
			},

			exclude_filetypes = {},
			exclude_buftypes = {},
		})
	end,
}
