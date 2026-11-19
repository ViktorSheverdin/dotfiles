-- Stop LSP servers when this nvim has been unfocused for a while, and bring
-- them back the moment you return.
--
-- Why: language servers (tsserver especially) grow their heap as you work and
-- never give it back. An nvim left open in another tmux window for days was
-- holding ~2.5G of tsserver + tailwind workers it wasn't using. Stopping the
-- server is the only way to actually return that memory to the OS.
--
-- Relies on FocusLost/FocusGained, which tmux forwards (`focus-events on`).
-- Switching tmux panes/windows counts as losing focus.

-- Override with `vim.g.lsp_idle_timeout_ms` before this file loads.
local IDLE_MS = vim.g.lsp_idle_timeout_ms or 15 * 60 * 1000 -- 15 min unfocused

local timer = assert(vim.uv.new_timer())
local stopped = false

local function stop_all()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
        return
    end
    for _, client in ipairs(clients) do
        client:stop()
    end
    stopped = true
end

local function restart_all()
    if not stopped then
        return
    end
    stopped = false
    -- vim.lsp.enable() attaches servers from a FileType autocmd in this
    -- group; replaying just that group re-attaches without re-running ftplugins.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "" then
            pcall(vim.api.nvim_exec_autocmds, "FileType", {
                group = "nvim.lsp.enable",
                buffer = buf,
                modeline = false,
            })
        end
    end
end

local group = vim.api.nvim_create_augroup("UserLspIdle", { clear = true })

vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = function()
        timer:stop()
        timer:start(IDLE_MS, 0, vim.schedule_wrap(stop_all))
    end,
})

vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
        timer:stop()
        restart_all()
    end,
})
