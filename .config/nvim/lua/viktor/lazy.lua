-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "viktor.plugins" },
		{ import = "viktor.plugins.lsp" },
	},

	-- Remove notifications about updates to the pluins
	change_detection = {
		notify = false,
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	-- install = { colorscheme = { "tokyonight" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- Workaround for a lazy.nvim timer leak (still present upstream as of 2026-11).
-- Upstream fix: https://github.com/folke/lazy.nvim/pull/2171 (open, unmerged).
-- Delete this block once that PR lands and lazy.nvim is updated.
-- lazy/manage/process.lua gives every git process a timeout timer, then on
-- exit calls timer:stop() but never timer:close(). A stopped-but-unclosed
-- libuv timer lives forever, and its callback keeps the whole Process object
-- (including the git output) alive. The update checker runs `git fetch` for
-- every plugin at startup and then hourly: 48 leaked timers per check, 11k
-- after 10 days of uptime. Fix: close the timer when the process exits.
-- `Process` is module-private, so grab it from the first spawned object.
do
	local proc_mod = require("lazy.manage.process")
	local spawn = proc_mod.spawn
	proc_mod.spawn = function(...)
		local proc = spawn(...)
		local Process = getmetatable(proc).__index
		if not Process._viktor_timer_fix then
			Process._viktor_timer_fix = true
			local on_exit = Process.on_exit
			function Process:on_exit(...)
				if self.timeout and not self.timeout:is_closing() then
					self.timeout:close()
				end
				return on_exit(self, ...)
			end
		end
		return proc
	end
end
