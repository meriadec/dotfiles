-- Disable default behavior of '-' (because leader)
vim.keymap.set({ 'n', 'v' }, '-', '<Nop>', { silent = true })

-- Dvorak buffer navigation
vim.keymap.set('n', '<Space>', '<NOP>')
vim.keymap.set('n', '<Space>h', ':wincmd h<CR>')
vim.keymap.set('n', '<Space>t', ':wincmd j<CR>')
vim.keymap.set('n', '<Space>n', ':wincmd k<CR>')
vim.keymap.set('n', '<Space>s', ':wincmd l<CR>')

-- Diagnostic navigation
vim.keymap.set('n', '<leader>N', function()
  vim.diagnostic.jump { count = -1 }
  vim.schedule(function()
    vim.diagnostic.open_float(nil, { focus = false })
  end)
end)
vim.keymap.set('n', '<leader>n', function()
  vim.diagnostic.jump { count = 1 }
  vim.schedule(function()
    vim.diagnostic.open_float(nil, { focus = false })
  end)
end)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Personal ones
vim.keymap.set('n', '<Leader>m', '^vg_o') -- select all line content
vim.keymap.set('n', '<Leader>o', ':%bd|e#<CR>') -- close all buffers except the current one
vim.keymap.set('n', '<Leader>p', 'p`[v`]') -- paste & select pasted text (after)
vim.keymap.set('n', '<Leader>P', 'P`[v`]') -- paste & select pasted text (before)
vim.keymap.set('n', 'Q', '<ESC>') -- never use Ex useless mode
vim.keymap.set({ 'n', 'i' }, '<c-s>', '<Esc>:x<CR>') -- c-s to save & quit

-- Magic insert mode jumps
vim.keymap.set('i', 'AA', '<Esc>A') -- quick command in insert mode: go to line end
vim.keymap.set('i', 'II', '<Esc>I') -- quick command in insert mode: go to line start
vim.keymap.set('i', 'OO', '<Esc>O') -- quick command in insert mode: go to line above

-- Save with <C-Enter>
vim.keymap.set('i', '<C-Enter>', '<C-O>:w<CR>')
vim.keymap.set('n', '<C-Enter>', ':w<CR>')
