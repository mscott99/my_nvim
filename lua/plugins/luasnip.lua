return {
{
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = function()
      require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath "config" .. "/luasnippets/" })
      -- reload will not work because I store my snippets in a different file, the module would have to be reloaded.
      require("luasnip").config.setup({
        enable_autosnippets = true,
        link_children = true, --autosnippets do not expand withing snippets
        store_selection_keys = "<Tab>",
      })
    end,
  },}
