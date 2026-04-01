return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- install parsers (replaces ensure_installed)
		require("nvim-treesitter").install({
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"css",
			"prisma",
			"markdown",
			"markdown_inline",
			"svelte",
			"graphql",
			"bash",
			"lua",
			"vim",
			"dockerfile",
			"gitignore",
			"query",
			"vimdoc",
			"c",
		})

		-- enable highlight + indent per filetype (now uses Neovim core APIs)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function(ev)
				pcall(vim.treesitter.start, ev.buf)
				vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")
	end,
}
