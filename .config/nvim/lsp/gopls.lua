return {
    settings = {
        gopls = {
            completeUnimported = true, -- suggest packages not yet imported (type `fmt.` → auto-adds import)
            usePlaceholders = true, -- fill function params as snippet placeholders on completion
            staticcheck = true, -- extra lint checks
            gofumpt = true, -- stricter formatting when formatting via LSP
            analyses = {
                unusedparams = true,
                unusedvariable = true,
                shadow = true,
            },
            hints = {
                parameterNames = true,
                assignVariableTypes = true,
                compositeLiteralFields = true,
            },
        },
    },
}
