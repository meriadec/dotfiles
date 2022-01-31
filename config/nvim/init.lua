_G.global = {}

local actions = require("fzf-lua.actions")

local u = require("utils")
local commands = require("commands")

vim.cmd("colorscheme nord")

vim.g.mapleader = "-" -- leader

vim.o.completeopt = "menuone,noselect" -- autocomplete
vim.opt.autoread = true -- auto reload files when changed
vim.opt.colorcolumn = "80" -- show the 80 chars column
vim.opt.cursorline = true -- show cursor line
vim.opt.encoding = "utf-8" -- encoding
vim.opt.expandtab = true -- use space to indent
vim.opt.helpheight = 99999 -- full page help
vim.opt.hidden = true -- don't write empty unsaved files
vim.opt.hlsearch = false -- prevent annoying highlight on search
vim.opt.ignorecase = true -- case insentitive search...
vim.opt.incsearch = true -- move on search
vim.opt.laststatus = 2 -- always show status bar
vim.opt.list = true -- show blank characters
vim.opt.listchars = "tab:>-,trail:·,nbsp:%" -- define blank characters
vim.opt.number = true -- show line numbers
vim.opt.pumheight = 10 -- maximum number of items to show in the popup menu
vim.opt.relativenumber = true -- relative line numbers
vim.opt.scrolloff = 5 -- number of lines to keep above & below cursor when scrolling
vim.opt.shiftwidth = 2 -- tab shiftwidth
vim.opt.sidescrolloff = 5 -- number of cols to keep above & below cursor when scrolling
vim.opt.signcolumn = "yes" -- show "lint" column
vim.opt.showmode = false -- show "lint" column
vim.opt.smartcase = true -- ...unless mixed case search
vim.opt.splitbelow = true -- behavior when splitting horizontally
vim.opt.splitright = true -- behavior when splitting vertically
vim.opt.swapfile = false -- don't create useless files
vim.opt.tabstop = 2 -- tab tabstop
vim.opt.termguicolors = true
vim.opt.termguicolors = true -- Enables 24-bit RGB color in the TUI
vim.opt.updatetime = 800 -- refresh rate
vim.opt.wb = false -- don't create useless files
vim.opt.wildmenu = true -- enable wild menu
vim.opt.wildmode = "longest,full" -- wild menu completion
vim.opt.wrap = false -- vim.opt.mouse = "c"
vim.opt.writebackup = false -- don't create useless files

vim.cmd("autocmd BufNewFile,BufRead tsconfig.json set filetype=jsonc")

require('packer').startup(function()

  use 'wbthomason/packer.nvim'

  use 'arcticicestudio/nord-vim'             -- theme

  use "SirVer/ultisnips"                     -- snippets
  use "hrsh7th/nvim-compe"                   -- completion
  use "ibhagwan/fzf-lua"                     -- fzf
  use "itchyny/lightline.vim"                -- lightline
  use "jose-elias-alvarez/nvim-lsp-ts-utils" -- typescript lsp utils
  use "kyazdani42/nvim-web-devicons"         -- icons
  use "lewis6991/gitsigns.nvim"              -- gitsigns
  use "mfussenegger/nvim-lsp-compl"          -- lsp completion
  use "mhartington/formatter.nvim"           -- formatter
  use "neovim/nvim-lspconfig"                -- lsp configuration
  use "norcalli/nvim-colorizer.lua"          -- colorizer
  use "nvim-lua/plenary.nvim"                -- utils
  use "scrooloose/nerdcommenter"             -- line comments
  use "towolf/vim-helm"                      -- helm syntax highlight
  use "vijaymarupudi/nvim-fzf"               -- fzf
  use "windwp/nvim-autopairs"                -- autopairs
  use "jparise/vim-graphql"                  -- graphql
  use "junegunn/goyo.vim"                    -- distraction free

  -- treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate"
  }

  -- emmet
  use {
    "mattn/emmet-vim",
    ft = { 'javascript', 'typescript.tsx', 'typescriptreact' }
  }

end)

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

local bonly = function(selected)
    commands.bwipeall()
    for _, file in ipairs(vim.list_slice(selected, 2)) do
        vim.cmd("e " .. file)
    end
end

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

local api = vim.api
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

local go_to_diagnostic = function(pos)
    return pos and api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
end

local next_diagnostic = function()
    go_to_diagnostic(lsp.diagnostic.get_next_pos() or lsp.diagnostic.get_prev_pos())
end

local prev_diagnostic = function()
    go_to_diagnostic(lsp.diagnostic.get_prev_pos() or lsp.diagnostic.get_next_pos())
end

_G.global.lsp = {
  popup_opts = popup_opts,
  next_diagnostic = next_diagnostic,
  prev_diagnostic = prev_diagnostic,
}

-- trigger only on letters and .
local trigger_characters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "." }

local on_attach = function(client, bufnr)
  -- commands
  u.lua_command("LspHover", "vim.lsp.buf.hover()")
  u.lua_command("LspRename", "vim.lsp.buf.rename()")
  u.lua_command("LspDiagPrev", "global.lsp.prev_diagnostic()")
  u.lua_command("LspDiagNext", "global.lsp.next_diagnostic()")
  u.lua_command("LspDiagLine", "vim.diagnostic.open_float(global.lsp.popup_opts)")
  u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

  u.buf_augroup("LspAutocommands", "CursorHold", "LspDiagLine")

  -- bindings
  u.buf_map("n", "gi", ":LspRename<CR>", nil, bufnr)
  u.buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
  u.buf_map("n", "<Leader>N", ":LspDiagPrev<CR>", nil, bufnr)
  u.buf_map("n", "<Leader>n", ":LspDiagNext<CR>", nil, bufnr)
  u.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

  -- fzf.lua
  u.buf_map("n", "gr", ":LspRefs<CR>", nil, bufnr)
  u.buf_map("n", "gd", ":LspDefs<CR>", nil, bufnr)
  u.buf_map("n", "gy", ":LspTypeDefs<CR>", nil, bufnr)
  u.buf_map("n", "ga", ":LspActions<CR>", nil, bufnr)

  if client.resolved_capabilities.completion then
    client.server_capabilities.completionProvider.triggerCharacters = trigger_characters
    -- require("lsp_compl").attach(client, bufnr)

    _G.global.lsp.completion = true
  end
end

local lspconfig = require('lspconfig')

require("lsp.sumneko").setup(on_attach)

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
u.lua_command("LspActions", 'require("fzf-lua").lsp_code_actions()')
u.lua_command("LspRefs", 'require("fzf-lua").lsp_references({ jump_to_single_result = true })')
u.lua_command("LspDefs", 'require("fzf-lua").lsp_definitions({ jump_to_single_result = true })')
u.lua_command("LspTypeDefs", 'require("fzf-lua").lsp_typedefs({ jump_to_single_result = true })')

-- dvorak buffer navigation
vim.cmd("nnoremap <Space> <NOP>")
vim.cmd("nmap <silent> <Space>h :wincmd h<CR>")
vim.cmd("nmap <silent> <Space>t :wincmd j<CR>")
vim.cmd("nmap <silent> <Space>n :wincmd k<CR>")
vim.cmd("nmap <silent> <Space>s :wincmd l<CR>")

-- remember last used position when opening file
vim.cmd("au BufReadPost * if line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif")

u.imap("<c-c>", "<Esc>") -- remap c-c to esc
u.imap("<c-f>", "<Esc>:Format<CR>i") -- reformat (on insert mode)
u.imap("<c-s>", "<Esc>:x<CR>") -- c-s to save (normal mode)
u.imap("AA", "<Esc>A") -- quick command in insert mode: go to line end
u.imap("II", "<Esc>I") -- quick command in insert mode: go to line start
u.imap("OO", "<Esc>O") -- quick command in insert mode: go to line above
u.map("n", "<CR>", "v:lua.global.commands.save_on_cr()", { expr = true }) -- save on press Enter
u.nmap("<C-p>", ":FzfLua files<CR>") -- c-p to open files
u.nmap("<Leader><Leader>", ":Format<CR>") -- reformat
u.nmap("<Leader>P", "P`[v`]")  -- paste & select pasted text (before)
u.nmap("<Leader>f", ":FzfLua grep_cword<CR>") -- fzf grep the current word
u.nmap("<Leader>m", "^vg_o") -- select all line content
u.nmap("<Leader>o", ":Bonly<CR>") -- close all buffers except the current one
u.nmap("<Leader>p", "p`[v`]") -- paste & select pasted text (after)
u.nmap("<c-f>", ":FzfLua live_grep<CR>") -- fzf live grep
u.nmap("<c-s>", ":x<CR>") -- c-s to save (insert mode)
u.nmap("Q", "<ESC>") -- never use Ex useless mode

-- ultisnips
vim.cmd("let g:UltiSnipsExpandTrigger=\"<tab>\"")
vim.cmd("let g:UltiSnipsJumpForwardTrigger=\"<tab>\"")
vim.cmd("let g:UltiSnipsJumpBackwardTrigger=\"<s-tab>\"")
vim.cmd("let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/ultisnips-snippets']")

-- nerd commenter
vim.cmd("let g:NERDSpaceDelims = 1")
vim.cmd("let g:NERDTrimTrailingWhitespace = 1")
vim.cmd("let g:NERDDefaultAlign = 'left'")

vim.cmd("let g:lightline = { 'colorscheme': 'nord' }")
