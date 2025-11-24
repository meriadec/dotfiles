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
  opts = function()
    local util = require 'conform.util'
    return {
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

      -- Define two Biome runners (operate on file via tempfile)
      formatters = {
        biome_check_write_unsafe = {
          command = 'biome',
          args = { 'check', '--write', '--unsafe', '$FILENAME' },
          stdin = false,
          tempfile = true,
          cwd = util.root_file {
            'biome.json',
            'biome.jsonc',
            'biome.config.*',
            'package.json',
          },
        },
        biome_format_write = {
          command = 'biome',
          args = { 'format', '--write', '$FILENAME' },
          stdin = false,
          tempfile = true,
          cwd = require('conform.util').root_file {
            'biome.json',
            'biome.jsonc',
            'biome.config.*',
            'package.json',
          },
        },
      },

      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        prisma = { 'prettierd', stop_after_first = true },
        css = { 'biome', 'prettierd', stop_after_first = true },
        jsonc = { 'biome', 'prettierd', stop_after_first = true },

        -- SOFT AUTO FORMAT
        -- typescript = { 'biome', 'prettierd', stop_after_first = true },
        -- typescriptreact = { 'biome', 'prettierd', stop_after_first = true },

        -- AWESOME AUTO FORMAT
        typescript = { 'biome_check_write_unsafe', 'biome_format_write' },
        typescriptreact = { 'biome_check_write_unsafe', 'biome_format_write' },

        json = { 'biome', 'prettierd', stop_after_first = true },
        markdown = { 'prettierd', stop_after_first = true },
      },
    }
  end,
}
