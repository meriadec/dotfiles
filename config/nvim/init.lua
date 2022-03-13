require 'core.global'
require 'core.options'
require 'core.mappings'
require 'modules.plugins'

-- plugins

require('gitsigns').setup()
require('colorizer').setup()
require('nvim-autopairs').setup()

local prettierd = {
   function()
      return {
        exe = "prettierd",
        args = {vim.api.nvim_buf_get_name(0)},
        stdin = true
      }
    end
}

require('formatter').setup({
  logging = false,
  filetype = {
    json = prettierd,
    jsonc = prettierd,
    css = prettierd,
    javascript = prettierd,
    html = prettierd,
    typescript = prettierd,
    typescriptreact = prettierd,
    yaml = prettierd,
    markdown = prettierd,
    graphql = prettierd,
  }
})

require("nvim-autopairs.completion.compe").setup({
  map_cr = true, -- map <CR> on insert mode
  map_complete = true, -- it will auto insert `(` after select function or method item
  auto_select = true,  -- auto select first item
})

require("nvim-treesitter.configs").setup({
    indent = { enable = true },
    ensure_installed = {
        "bash",
        "javascript",
        "typescript",
        "tsx",
        "lua",
        "json",
        "jsonc",
        "yaml",
    },
    highlight = { enable = true },
    autopairs = { enable = true },
})

require('compe').setup({
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  resolve_timeout = 800;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 64,
    min_width = 48,
    min_height = 3,
  };
  auto_select = true,  -- auto select first item
  source = {
    nvim_lsp = true;
    nvim_lua = true;
    ultisnips = false;
  };
})

local commands = require("commands")

local bonly = function(selected)
    commands.bwipeall()
    for _, file in ipairs(vim.list_slice(selected, 2)) do
        vim.cmd("e " .. file)
    end
end

local actions = require("fzf-lua.actions")

local file_actions = {
  ["default"] = actions.file_edit,
  ["ctrl-v"]  = actions.file_vsplit,
  ["ctrl-x"]  = actions.file_split,
  ["ctrl-t"]  = actions.file_tabedit,
  ["ctrl-q"]  = actions.file_sel_to_qf,
  ["ctrl-o"]  = bonly,
}

require("fzf-lua").setup({
  fzf_layout = "default",
  winopts = { win_height = 0.7, win_width = 0.90 },
  -- fzf_binds = { "ctrl-u:clear-query", "alt-p:toggle-preview" },
  previewers = {
    bat = {
      cmd    = "bat",
      args   = "--style=numbers,changes --color always",
      theme  = 'Nord',
      config = nil,
    },
  },
  files = { actions = file_actions },
  grep = {
    rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case",
    actions = file_actions,
  },
})

local lsp = vim.lsp

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    signs = true,
    virtual_text = true,
})

vim.fn.sign_define("LspDiagnosticsSignError",       { text = "", texthl = "ALEErrorSign" })
vim.fn.sign_define("LspDiagnosticsSignWarning",     { text = "", texthl = "ALEWarning"})
vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "", texthl = "FoldColumn"})
vim.fn.sign_define("LspDiagnosticsSignHint",        { text = "", texthl = "FoldColumn"})

local popup_opts = {
  border = "none",
  focusable = false,
  show_header = false,
  max_width = 64,
}

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)

local next_diagnostic = function()
    vim.diagnostic.goto_next()
end

local prev_diagnostic = function()
    vim.diagnostic.goto_prev()
end

_G.global.lsp = {
  popup_opts = popup_opts,
  next_diagnostic = next_diagnostic,
  prev_diagnostic = prev_diagnostic,
}

-- trigger only on letters and .
local trigger_characters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "." }

local utils = require("utils")

local on_attach = function(client, bufnr)
  -- commands
  utils.lua_command("LspHover", "vim.lsp.buf.hover()")
  utils.lua_command("LspRename", "vim.lsp.buf.rename()")
  utils.lua_command("LspDiagPrev", "global.lsp.prev_diagnostic()")
  utils.lua_command("LspDiagNext", "global.lsp.next_diagnostic()")
  utils.lua_command("LspDiagLine", "vim.diagnostic.open_float(global.lsp.popup_opts)")
  utils.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

  utils.buf_augroup("LspAutocommands", "CursorHold", "LspDiagLine")

  -- bindings
  utils.buf_map("n", "gi", ":LspRename<CR>", nil, bufnr)
  utils.buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
  utils.buf_map("n", "<Leader>N", ":LspDiagPrev<CR>", nil, bufnr)
  utils.buf_map("n", "<Leader>n", ":LspDiagNext<CR>", nil, bufnr)
  utils.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

  -- fzf.lua
  utils.buf_map("n", "gr", ":LspRefs<CR>", nil, bufnr)
  utils.buf_map("n", "gd", ":LspDefs<CR>", nil, bufnr)
  utils.buf_map("n", "gy", ":LspTypeDefs<CR>", nil, bufnr)
  utils.buf_map("n", "ga", ":LspActions<CR>", nil, bufnr)

  if client.resolved_capabilities.completion then
    client.server_capabilities.completionProvider.triggerCharacters = trigger_characters
    _G.global.lsp.completion = true
  end
end

local lspconfig = require('lspconfig')

require("modules.lsp.sumneko").setup(on_attach)

lspconfig.bashls.setup({
  on_attach = on_attach,
  filetypes = { "sh" }
})

lspconfig.flow.setup({ on_attach = on_attach })
lspconfig.tailwindcss.setup({ on_attach = on_attach })

lspconfig.tsserver.setup({
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" }
})

-- lsp
utils.lua_command("LspActions", 'require("fzf-lua").lsp_code_actions()')
utils.lua_command("LspRefs", 'require("fzf-lua").lsp_references({ jump_to_single_result = true })')
utils.lua_command("LspDefs", 'require("fzf-lua").lsp_definitions({ jump_to_single_result = true })')
utils.lua_command("LspTypeDefs", 'require("fzf-lua").lsp_typedefs({ jump_to_single_result = true })')

-- ultisnips
vim.cmd("let g:UltiSnipsExpandTrigger=\"<tab>\"")
vim.cmd("let g:UltiSnipsJumpForwardTrigger=\"<tab>\"")
vim.cmd("let g:UltiSnipsJumpBackwardTrigger=\"<s-tab>\"")
vim.cmd("let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/ultisnips-snippets']")

-- nerd commenter
vim.cmd("let g:NERDSpaceDelims = 1")
vim.cmd("let g:NERDTrimTrailingWhitespace = 1")
vim.cmd("let g:NERDDefaultAlign = 'left'")

-- lightline
vim.cmd("let g:lightline = { 'colorscheme': 'nord' }")
