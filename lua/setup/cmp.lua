-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
-- require('luasnip.loaders.from_vscode').lazy_load()

require('luasnip.loaders.from_lua').load { paths = vim.fn.stdpath 'config' .. '/lua/snippets/luasnippets/' }
-- reload will not work because I store my snippets in a different file, the module would have to be reloaded.
require('luasnip').config.setup {
  enable_autosnippets = true,
  link_children = true, --autosnippets do not expand withing snippets
  store_selection_keys = '<Tab>',
}

local function can_pass_delimiter()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local char = line:sub(col + 1, col + 1)
  local delimiters = { ')', ']', "'", '"' }

  for _, delimiter in ipairs(delimiters) do
    if char == delimiter then
      return true
    end
  end
  return false
end

local function move_cursor_right()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col + 1 })
end

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  dependencies = {
    { 'ray-x/cmp-treesitter' },
    {
      'benfowler/telescope-luasnip.nvim',
      config = function()
        require('telescope').load_extension 'luasnip'
      end,
    },
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
    -- keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]]
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(4),
    ['<C-Q>'] = cmp.mapping.abort(),
    ['<C-l>'] = cmp.mapping.complete {},
    ['<C-Space>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if can_pass_delimiter() then
        move_cursor_right()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
        -- elseif cmp.visible() then
        -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
        -- cmp.select_next_item()
        -- cmp.confirm({ select = true })
        -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
        -- this way you will only jump inside the snippet region
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'copilot' }, -- not using cmp-comp
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'otter' }, -- for code chunks in quarto
    { name = 'treesitter', keyword_length = 5, max_item_count = 3 },
  },
  -- experimental = {
  -- ghost_text = {
  --   hl_group = 'CmpGhostText',
  -- },
  -- },
}
