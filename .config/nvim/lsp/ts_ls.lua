return {
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
    init_options = {
        hostInfo = "neovim",
        maxTsServerMemory = 12288,
        preferences = {
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
        },
    },
    settings = {
        typescript = {
            tsserver = { maxTsServerMemory = 12288 },
            preferences = { importModuleSpecifier = "non-relative" },
        },
        javascript = {
            tsserver = { maxTsServerMemory = 12288 },
        },
    },
}
