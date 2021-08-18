local u = require("utils")
local sumneko = require("lsp.sumneko")
local null_ls = require("lsp.null-ls")
local tsserver = require("lsp.tsserver")

local api = vim.api
local lsp = vim.lsp

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    signs = true,
    virtual_text = false,
})

local popup_opts = { border = "single", focusable = false }

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)

local go_to_diagnostic = function(pos)
    return pos and api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
end

local next_diagnostic = function()
    go_to_diagnostic(lsp.diagnostic.get_next_pos() or lsp.diagnostic.get_prev_pos())
end

local prev_diagnostic = function()
    go_to_diagnostic(lsp.diagnostic.get_prev_pos() or lsp.diagnostic.get_next_pos())
end

-- trigger only on letters and .
local trigger_characters = {
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "0",
    ".",
}

_G.global.lsp = {
    popup_opts = popup_opts,
    next_diagnostic = next_diagnostic,
    prev_diagnostic = prev_diagnostic,
}

local on_attach = function(client, bufnr)
    -- commands
    u.lua_command("LspFormatting", "vim.lsp.buf.formatting()")
    u.lua_command("LspHover", "vim.lsp.buf.hover()")
    u.lua_command("LspRename", "vim.lsp.buf.rename()")
    u.lua_command("LspDiagPrev", "global.lsp.prev_diagnostic()")
    u.lua_command("LspDiagNext", "global.lsp.next_diagnostic()")
    u.lua_command("LspDiagLine", "vim.lsp.diagnostic.show_line_diagnostics(global.lsp.popup_opts)")
    u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

    u.buf_augroup("LspAutocommands", "CursorHold", "LspDiagLine")

    -- bindings
    u.buf_map("n", "gi", ":LspRename<CR>", nil, bufnr)
    u.buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
    u.buf_map("n", "[a", ":LspDiagPrev<CR>", nil, bufnr)
    u.buf_map("n", "]a", ":LspDiagNext<CR>", nil, bufnr)
    u.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

    -- fzf.lua
    u.buf_map("n", "gr", ":LspRefs<CR>", nil, bufnr)
    u.buf_map("n", "gd", ":LspDefs<CR>", nil, bufnr)
    u.buf_map("n", "gy", ":LspTypeDefs<CR>", nil, bufnr)
    u.buf_map("n", "ga", ":LspActions<CR>", nil, bufnr)

    if client.resolved_capabilities.document_formatting then
        u.buf_augroup("LspFormatOnSave", "BufWritePre", "lua vim.lsp.buf.formatting_sync()")
    end

    if client.resolved_capabilities.completion then
        client.server_capabilities.completionProvider.triggerCharacters = trigger_characters
        --require("lsp_compl").attach(client, bufnr)

        _G.global.lsp.completion = true
    end
end

tsserver.setup(on_attach)
sumneko.setup(on_attach)
null_ls.setup(on_attach)
