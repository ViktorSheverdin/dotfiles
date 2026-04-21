vim.cmd("let g:netrw_liststyle = 3") -- sets the netrw file explorer to use a tree-style listing instead of the default flat list

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- Over SSH, the "system clipboard" on the remote host is useless — we want
-- yanks to land on the *local* machine's clipboard. OSC 52 tunnels clipboard
-- writes through the terminal escape stream back to the local terminal
-- (WezTerm, kitty, etc.) which then writes to the real system clipboard.
--
-- Detection is a little involved because a tmux pane's process environment
-- can be stale: shells spawned before you SSH'd in (or restored by
-- tmux-resurrect) won't have SSH_TTY/SSH_CONNECTION set, even though you're
-- currently attached over SSH. tmux itself refreshes its *session* env on
-- each attach (see `update-environment`), so when the pane env looks clean
-- we fall back to asking tmux directly.
local function is_ssh()
  if vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT then
    return true
  end
  if vim.env.TMUX then
    local out = vim.fn.system("tmux show-environment SSH_CONNECTION 2>/dev/null")
    -- Present and not unset (tmux prefixes unset vars with "-")
    if out:match("^SSH_CONNECTION=") then
      return true
    end
  end
  return false
end

if is_ssh() then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- auto-reload files changed outside of nvim (e.g. by Claude Code)
opt.autoread = true

-- On focus/buffer switch (fallback for files not yet watched)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Live file watching using OS-native events (inotify on Linux, FSEvents on macOS).
-- Each buffer gets a watcher that fires instantly when the file changes on disk,
-- triggering checktime to reload it — no polling, zero CPU overhead when idle.
local uv = vim.uv or vim.loop
local watchers = {}

local function watch_buffer(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr) -- get the file path for this buffer
  if path == "" or vim.fn.filereadable(path) ~= 1 then return end -- skip unnamed or unreadable buffers
  if watchers[bufnr] then return end -- already watching this buffer, skip

  local handle = uv.new_fs_event()  -- create a new OS file system event handle
  if not handle then return end      -- bail if the OS couldn't create a watcher
  watchers[bufnr] = handle           -- store handle so we can stop it later

  -- start watching the file; callback fires instantly when the OS detects a change
  handle:start(path, {}, vim.schedule_wrap(function(err, _, _)
    if not err and vim.api.nvim_buf_is_valid(bufnr) then
      vim.cmd("checktime " .. bufnr) -- tell nvim to re-read the file from disk
    end
  end))
end

local function unwatch_buffer(bufnr)
  local handle = watchers[bufnr] -- look up the watcher for this buffer
  if handle then
    handle:stop()              -- unregister the OS file system event
    watchers[bufnr] = nil      -- free the reference
  end
end

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args) watch_buffer(args.buf) end,
})
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args) unwatch_buffer(args.buf) end,
})
