local lspconfig = require("lspconfig")
local ts_utils = require("nvim-lsp-ts-utils")

local ts_utils_settings = {
    -- debug = true,
    import_all_scan_buffers = 100,
    eslint_bin = "eslint",
    eslint_enable_diagnostics = true,
    eslint_show_rule_id = true,
    enable_formatting = true,
    formatter = "prettier",
    update_imports_on_move = true,
}

local M = {}
M.setup = function(on_attach)
    lspconfig.tsserver.setup({
        on_attach = function(client, bufnr)
            client.resolved_capabilities.document_formatting = false
            client.resolved_capabilities.document_range_formatting = false

            on_attach(client, bufnr)

            ts_utils.setup(ts_utils_settings)
            ts_utils.setup_client(client)
        end,
        flags = {
            debounce_text_changes = 150,
        },
    })
end

return M
