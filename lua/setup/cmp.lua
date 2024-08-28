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

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  dependencies = {
    { "ray-x/cmp-treesitter" },
    {"benfowler/telescope-luasnip.nvim",
      config = function()
        require('telescope').load_extension('luasnip')
      end
    }
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(4),
    ['<C-Q>'] = cmp.mapping.abort(),
    -- ['<C-Space>'] = cmp.mapping.complete {},
    ['<C-Space>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
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
    { name = "otter" },       -- for code chunks in quarto
    { name = "treesitter", keyword_length = 5, max_item_count = 3 },
  },
  -- experimental = {
    -- ghost_text = {
    --   hl_group = 'CmpGhostText',
    -- },
  -- },
}
