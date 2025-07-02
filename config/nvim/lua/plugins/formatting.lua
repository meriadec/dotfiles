-- Formatting

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<Leader><Leader>',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      prisma = { 'prettierd', stop_after_first = true },
      css = { 'biome', 'prettierd', stop_after_first = true },
      javascript = { 'biome', 'prettierd', stop_after_first = true },
      javascriptreact = { 'biome', 'prettierd', stop_after_first = true },
      typescript = { 'biome', 'prettierd', stop_after_first = true },
      typescriptreact = { 'biome', 'prettierd', stop_after_first = true },
      json = { 'biome', 'prettierd', stop_after_first = true },
      markdown = { 'prettierd', stop_after_first = true },
    },
  },
}
