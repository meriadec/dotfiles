_G.global = {}

require 'options'
require 'mappings'

require 'impatient'

require('packer').startup(function()

  use 'wbthomason/packer.nvim' -- package manager
  use 'lewis6991/impatient.nvim' -- improve startup time

  use "nvim-lua/plenary.nvim" -- utils (required by some stuff)
  use 'jose-elias-alvarez/null-ls.nvim' -- utils (required by eslint)

  use 'arcticicestudio/nord-vim' -- theme

  use "SirVer/ultisnips" -- snippets
  use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"} -- treesitter
  use "onsails/lspkind.nvim" -- icons
  use "hrsh7th/nvim-cmp" -- completion
  use "hrsh7th/cmp-nvim-lsp" -- nvim-cmp source for lsp
  use "nvim-telescope/telescope.nvim" -- telescope
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'}
  use {'nvim-telescope/telescope-ui-select.nvim'}
  use "itchyny/lightline.vim" -- lightline
  use "jose-elias-alvarez/nvim-lsp-ts-utils" -- typescript lsp utils
  use "kyazdani42/nvim-web-devicons" -- icons
  use "lewis6991/gitsigns.nvim" -- gitsigns
  use "mhartington/formatter.nvim" -- formatter
  use "neovim/nvim-lspconfig" -- lsp configuration
  use "norcalli/nvim-colorizer.lua" -- colorizer
  use {
    "mattn/emmet-vim",
    ft = {'javascript', 'typescript.tsx', 'typescriptreact'}
  } -- emmet
  use "scrooloose/nerdcommenter" -- line comments
  use "towolf/vim-helm" -- helm syntax highlight
  use "windwp/nvim-autopairs" -- autopairs
  use "jparise/vim-graphql" -- graphql
  use 'MunifTanjim/eslint.nvim' -- eslint

end)

local utils = require("utils")

-- plugins

require('colorizer').setup()
require('nvim-autopairs').setup()
require('gitsigns').setup()

local telescopeActions = require("telescope.actions")
require('telescope').setup({
  extensions = {["ui-select"] = {require("telescope.themes").get_cursor {}}},
  defaults = {
    prompt_title = false,
    results_title = false,
    preview_title = false,
    prompt_prefix = "     ",
    selection_caret = "  ",
    entry_prefix = "  ",
    layout_config = {horizontal = {preview_width = 0.7, results_width = 0.3}},
    mappings = {i = {["<esc>"] = telescopeActions.close}}
  }
})
require('telescope').load_extension('fzf')
require("telescope").load_extension("ui-select")

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
    graphql = prettierd
  }
})

require("nvim-treesitter.configs").setup({
  indent = {enable = true},
  ensure_installed = {
    "bash", "javascript", "typescript", "tsx", "lua", "json", "jsonc", "yaml"
  },
  highlight = {enable = true},
  autopairs = {enable = true}
})

local popup_opts = {
  border = "none",
  focusable = false,
  show_header = false,
  max_width = 64
}

_G.global.lsp = {popup_opts = popup_opts}

local for_each_buffer = function(cb, force)
  utils.for_each(vim.fn.getbufinfo({buflisted = true}),
                 function(b) if b.changed == 0 and not force then cb(b) end end)
end

_G.global.bonly = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  for_each_buffer(function(b)
    if b.bufnr ~= bufnr then vim.cmd("silent! bdelete " .. b.bufnr) end
  end)
end

utils.lua_command("Bonly", "global.bonly()")

local on_attach = function(client, bufnr)
  -- commands
  utils.lua_command("LspHover", "vim.lsp.buf.hover()")
  utils.lua_command("LspRename", "vim.lsp.buf.rename()")
  utils.lua_command("LspDiagPrev", "vim.diagnostic.goto_prev()")
  utils.lua_command("LspDiagNext", "vim.diagnostic.goto_next()")
  utils.lua_command("LspDiagLine",
                    "vim.diagnostic.open_float(global.lsp.popup_opts)")
  utils.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

  utils.buf_augroup("LspAutocommands", "CursorHold", "LspDiagLine")

  -- bindings
  utils.buf_map("n", "gi", ":LspRename<CR>", nil, bufnr)
  utils.buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
  utils.buf_map("n", "<Leader>N", ":LspDiagPrev<CR>", nil, bufnr)
  utils.buf_map("n", "<Leader>n", ":LspDiagNext<CR>", nil, bufnr)
  utils.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

  -- lsp
  utils.buf_map("n", "gr", ":LspRefs<CR>", nil, bufnr)
  utils.buf_map("n", "gd", ":LspDefs<CR>", nil, bufnr)
  utils.buf_map("n", "gy", ":LspTypeDefs<CR>", nil, bufnr)
  utils.buf_map("n", "ga", ":LspActions<CR>", nil, bufnr)

  if client.resolved_capabilities.completion then
    local trigger_characters = {
      "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
      "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D",
      "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
      "T", "U", "V", "W", "X", "Y", "Z", "0", "."
    }
    client.server_capabilities.completionProvider.triggerCharacters =
      trigger_characters
    _G.global.lsp.completion = true
  end
end

-- lsp
utils.lua_command("LspActions", 'vim.lsp.buf.code_action()')
utils.lua_command("LspRefs", 'require("telescope.builtin").lsp_references()')
utils.lua_command("LspDefs", 'require("telescope.builtin").lsp_definitions()')
utils.lua_command("LspTypeDefs",
                  'require("telescope.builtin").lsp_type_definitions()')

-- ultisnips
vim.cmd("let g:UltiSnipsExpandTrigger=\"<tab>\"")
vim.cmd("let g:UltiSnipsJumpForwardTrigger=\"<tab>\"")
vim.cmd("let g:UltiSnipsJumpBackwardTrigger=\"<s-tab>\"")
vim.cmd(
  "let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/ultisnips-snippets']")

-- nerd commenter
vim.cmd("let g:NERDSpaceDelims = 1")
vim.cmd("let g:NERDTrimTrailingWhitespace = 1")
vim.cmd("let g:NERDDefaultAlign = 'left'")

-- lightline
vim.cmd("let g:lightline = { 'colorscheme': 'nord' }")

-- eslint

local null_ls = require("null-ls")
local eslint = require("eslint")

null_ls.setup()

eslint.setup({
  bin = 'eslint_d', -- or `eslint_d`
  code_actions = {
    enable = true,
    apply_on_save = {
      enable = false,
      types = {"problem"} -- "directive", "problem", "suggestion", "layout"
    },
    disable_rule_comment = {
      enable = true,
      location = "separate_line" -- or `same_line`
    }
  },
  diagnostics = {
    enable = true,
    report_unused_disable_directives = false,
    run_on = "type" -- or `save`
  }
})

local signs = {Error = "", Warn = "", Hint = "", Info = ""}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

-- nvim-cmp
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({select = true}) -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({{name = 'nvim_lsp'}, {name = 'ultisnips'}},
                               {{name = 'buffer'}})
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {{name = 'buffer'}}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({{name = 'path'}}, {{name = 'cmdline'}})
})

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp
                                                                   .protocol
                                                                   .make_client_capabilities())

local lspconfig = require('lspconfig')

lspconfig.tsserver.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"typescript", "typescriptreact", "typescript.tsx"}
})

lspconfig.bashls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"sh"}
})

lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"python"}
})

lspconfig.sumneko_lua.setup({
  on_attach = on_attach,
  cmd = {
    "/usr/bin/lua-language-server", "-E",
    "/usr/share/lua-language-server/" .. "main.lua"
  },
  settings = {
    Lua = {
      runtime = {version = "LuaJIT"},
      diagnostics = {
        enable = true,
        globals = {
          "vim", "use", "describe", "it", "assert", "before_each", "after_each"
        }
      }
    }
  },
  flags = {debounce_text_changes = 150}
})

lspconfig.flow.setup({on_attach = on_attach, capabilities = capabilities})

lspconfig.tailwindcss
  .setup({on_attach = on_attach, capabilities = capabilities})

lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"rust"}
})

-- lspkind
local lspkind = require('lspkind')
cmp.setup {
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      ---@diagnostic disable-next-line: unused-local
      before = function(entry, vim_item) return vim_item end
    })
  }
}
