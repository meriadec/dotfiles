vim.api.nvim_create_user_command('TsGetFiles', function()
  vim.fn.setreg('q', 'vwwhdf:d$0', 'n')
  vim.cmd '%normal! @q'
  vim.cmd 'normal! ggVGJ'
  vim.cmd 'normal! Ivim '
  vim.cmd 'normal! $'
end, {})
