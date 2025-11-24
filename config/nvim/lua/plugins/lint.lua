return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {}

      local function project_has_file(names)
        local buf = vim.api.nvim_buf_get_name(0)
        local dir = buf ~= '' and vim.fs.dirname(buf) or vim.fn.getcwd()
        if not dir or dir == '' then
          return false
        end

        local uv = vim.uv or vim.loop
        local visited = {}

        while dir and dir ~= '' and not visited[dir] do
          visited[dir] = true
          for _, name in ipairs(names) do
            if uv.fs_stat(dir .. '/' .. name) then
              return true
            end
          end
          local parent = vim.fs.dirname(dir)
          if not parent or parent == dir then
            break
          end
          dir = parent
        end

        return false
      end

      local function should_use_eslint()
        return project_has_file {
          '.eslintrc',
          '.eslintrc.js',
          '.eslintrc.cjs',
          'eslint.config.js',
          'eslint.config.mjs',
          'eslint.config.cjs',
        }
      end

      local function should_use_biome()
        return project_has_file { 'biome.json', 'biome.jsonc' }
      end

      -- Create autocommand which carries out the actual linting on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          if not vim.opt_local.modifiable:get() then
            return
          end
          if vim.tbl_contains({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }, vim.bo.filetype) then
            if should_use_biome() then
              lint.try_lint 'biomejs'
            elseif should_use_eslint() then
              lint.try_lint 'eslint_d'
            end
          else
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
