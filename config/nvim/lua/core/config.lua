-- Border for signature help floating bubble
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or 'rounded'
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Retrieve last edited line when opening file
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.fn.line [['"]]
    if mark > 1 and mark <= vim.fn.line '$' then
      vim.cmd [[normal! g`"]]
    end
  end,
})

-- Properly highlight json5 files
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = 'tsconfig.json',
  callback = function()
    vim.bo.filetype = 'jsonc'
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
