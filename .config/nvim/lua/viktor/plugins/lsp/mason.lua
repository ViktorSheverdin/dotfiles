-- Go tools (gopls, goimports, delve) are built with `go install`, so mason
-- fails on every startup on machines without a Go toolchain. Only ask for
-- them where `go` exists.
local has_go = vim.fn.executable("go") == 1

local servers = {
    "ts_ls",
    "html",
    "cssls",
    "tailwindcss",
    "lua_ls",
    "graphql",
    "prismals",
    "pyright",
}

local tools = {
    "prettier", -- prettier formatter
    "stylua", -- lua formatter
    "eslint_d",
    -- isort, black, pylint installed via pipx (brew install pipx)
}

if has_go then
    table.insert(servers, "gopls")
    table.insert(tools, "goimports") -- go formatter + auto add/remove imports
end

return {
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            -- list of servers for mason to install
            ensure_installed = servers,
        },
        dependencies = {
            {
                "williamboman/mason.nvim",
                opts = {
                    ui = {
                        icons = {
                            package_installed = "✓",
                            package_pending = "➜",
                            package_uninstalled = "✗",
                        },
                    },
                },
            },
            "neovim/nvim-lspconfig",
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            ensure_installed = tools,
        },
        dependencies = {
            "williamboman/mason.nvim",
        },
    },
}
