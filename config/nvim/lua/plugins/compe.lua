require('compe').setup({
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';

  throttle_time = 0;
  source_timeout = 0;
  resolve_timeout = 0;
  incomplete_delay = 0;
  -- throttle_time = 80;
  -- source_timeout = 200;
  -- resolve_timeout = 800;
  -- incomplete_delay = 400;

  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  -- map_cr = true, --  map <CR> on insert mode
  -- map_complete = true, -- it will auto insert `(` after select function or method item
  -- auto_select = false,  -- auto select first item

  source = {
    -- path = true;
    -- buffer = true;
    -- calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
    ultisnips = true;
    luasnip = true;
  };
})
