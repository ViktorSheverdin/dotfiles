-- Go uses tabs (gofmt standard); override global expandtab
vim.opt_local.expandtab = false
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4

-- run / test the package containing this file in a split terminal
local function in_term(cmd)
	local dir = vim.fn.shellescape(vim.fn.expand("%:p:h"))
	vim.cmd("botright split | resize 15 | terminal cd " .. dir .. " && " .. cmd)
end

local opts = { buffer = true }
vim.keymap.set("n", "<leader>rr", function()
	in_term("go run .")
end, vim.tbl_extend("force", opts, { desc = "Go: run package" }))
vim.keymap.set("n", "<leader>rt", function()
	in_term("go test -v .")
end, vim.tbl_extend("force", opts, { desc = "Go: test package" }))
vim.keymap.set("n", "<leader>dT", function()
	require("dap-go").debug_test()
end, vim.tbl_extend("force", opts, { desc = "Go: debug test under cursor" }))
