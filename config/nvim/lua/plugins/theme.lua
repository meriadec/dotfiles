-- Colorscheme

return {
  'gbprod/nord.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('nord').setup {
      styles = {
        comments = { italic = false }, -- Disable italics in comments
      },
    }
    vim.cmd.colorscheme 'nord'
  end,
}
