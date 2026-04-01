return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
		current_line_blame = true,
		current_line_blame_opts = {
			virt_text_pos = "eol",
			delay = 0,
		},
		current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
	},
}
