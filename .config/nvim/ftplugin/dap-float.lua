-- nvim-dap hover/scopes floats (<leader>dh) take focus and don't auto-close.
-- q or <Esc> closes them.
local opts = { buffer = true, silent = true, nowait = true, desc = "Close dap float" }
vim.keymap.set("n", "q", "<cmd>close<CR>", opts)
vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", opts)
