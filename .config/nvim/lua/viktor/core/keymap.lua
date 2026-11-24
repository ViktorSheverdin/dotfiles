local keymap = vim.keymap -- for conciseness

-- save
keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save file" })

-- clear search highlights on Esc
keymap.set("n", "<Esc>", "<cmd>nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management (w = window)
keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>wh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close current split" })

-- buffer navigation (tab-like)
keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<S-x>", function()
	Snacks.bufdelete()
end, { desc = "Close buffer" })

-- tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- marks: `m{letter}` sets one, these remove them (Snacks statuscolumn shows marks in the sign column)
-- dm: delete every mark on the cursor line, whatever its letter
keymap.set("n", "dm", function()
	local buf, line = vim.api.nvim_get_current_buf(), vim.fn.line(".")
	local gone = {}
	-- lowercase marks belong to this buffer
	for _, m in ipairs(vim.fn.getmarklist(buf)) do
		local name = m.mark:sub(2)
		if name:match("^%l$") and m.pos[2] == line then
			vim.api.nvim_buf_del_mark(buf, name)
			gone[#gone + 1] = name
		end
	end
	-- uppercase marks are global: only take the ones pointing at this line of this buffer
	for _, m in ipairs(vim.fn.getmarklist()) do
		local name = m.mark:sub(2)
		if name:match("^%u$") and m.pos[1] == buf and m.pos[2] == line then
			vim.api.nvim_del_mark(name)
			gone[#gone + 1] = name
		end
	end
	if #gone > 0 then
		vim.cmd("redraw!")
		vim.notify("Deleted mark " .. table.concat(gone, ", "))
	else
		vim.notify("No mark on this line")
	end
end, { desc = "Delete marks on this line" })
keymap.set("n", "dM", "<cmd>delmarks!<CR>", { desc = "Delete all lowercase marks in buffer" })
