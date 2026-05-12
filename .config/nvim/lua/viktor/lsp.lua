local keymap = vim.keymap -- for conciseness

vim.api.nvim_create_user_command("LspRestart", function(opts)
    local filter = opts.args ~= "" and { name = opts.args } or nil
    local clients = vim.lsp.get_clients(filter)
    if #clients == 0 then
        vim.notify("LspRestart: no matching clients", vim.log.levels.WARN)
        return
    end
    for _, c in ipairs(clients) do
        vim.lsp.stop_client(c.id)
    end
    vim.defer_fn(function()
        vim.cmd("edit")
    end, 200)
end, { nargs = "?", desc = "Restart LSP client(s)" })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        -- NOTE: gd, gD, gr, gI, gy, gai, gao are handled by Snacks picker in snacks.lua

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        -- NOTE: buffer diagnostics handled by Snacks picker (<leader>sD) in snacks.lua

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, opts) -- jump to previous diagnostic in buffer
        --
        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end,
})

-- vim.lsp.inlay_hint.enable(true)

local severity = vim.diagnostic.severity

vim.diagnostic.config({
    signs = {
        text = {
            [severity.ERROR] = "❌",
            [severity.WARN] = "⚠️",
            [severity.HINT] = "💡",
            [severity.INFO] = "ℹ️",
        },
    },
})
