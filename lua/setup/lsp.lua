--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>cr', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ss', require('telescope.builtin').lsp_document_symbols, 'Document [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')

  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Signature Documentation' })



  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- local on_attach_qmd = function(client, bufnr)
--   local function buf_set_keymap(...)
--     vim.api.nvim_buf_set_keymap(bufnr, ...)
--   end
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
--   local opts = { noremap = true, silent = true }
--
--   buf_set_keymap("n", "gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
--   buf_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
--   buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
--   buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
--   buf_set_keymap("n", "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", opts)
--   client.server_capabilities.document_formatting = true
-- end
--
-- local lsp_flags = {
--   allow_incremental_sync = true,
--   debounce_text_changes = 150,
-- }

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  -- ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' }, is already a shortcut.
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  -- ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local util = require("lspconfig.util")
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- local lsp_flags = {
--   allow_incremental_sync = true,
--   debounce_text_changes = 150,
-- }
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  -- noisy errors about ambiguous links
  -- marksman = {},
  pyright = {
    -- settings = {
      -- python = {
      --   stubPath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs",
      --   analysis = {
      --     autoSearchPaths = true,
      --     useLibraryCodeForTypes = false,
      --     diagnosticMode = "openFilesOnly",
      --   },
      -- },
    -- },
    -- root_dir = function(fname)
    --   return util.root_pattern(".obsidian", ".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(
    --     fname
    --   ) or util.path.dirname(fname)
    -- end,
  },
  julials = {},
  typst_lsp = {
    settings = {
      exportPdf = "never",
    },
  },
  tsserver = {}
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

require'lspconfig'.mojo.setup{}

-- local function strsplit(s, delimiter)
--   local result = {}
--   for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
--     table.insert(result, match)
--   end
--   return result
-- end
--
-- local function get_quarto_resource_path()
--   local f = assert(io.popen("quarto --paths", "r"))
--   local s = assert(f:read("*a"))
--   f:close()
--   return strsplit(s, "\n")[2]
-- end
--
-- local lua_library_files = vim.api.nvim_get_runtime_file("", true)
-- local lua_plugin_paths = {}
-- local resource_path = get_quarto_resource_path()
-- if resource_path == nil then
--   vim.notify_once("quarto not found, lua library files not loaded")
-- else
--   table.insert(lua_library_files, resource_path .. "/lua-types")
--   table.insert(lua_plugin_paths, resource_path .. "/lua-plugin/plugin.lua")
-- end
--
-- require('lspconfig').lua_ls.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
--   flags = lsp_flags,
--   settings = {
--     Lua = {
--       completion = {
--         callSnippet = "Replace",
--       },
--       runtime = {
--         version = "LuaJIT",
--         plugin = lua_plugin_paths,
--       },
--       diagnostics = {
--         globals = { "vim", "quarto", "pandoc", "io", "string", "print", "require", "table" },
--         disable = { "trailing-space" },
--       },
--       workspace = {
--         library = lua_library_files,
--         checkThirdParty = false,
--       },
--       telemetry = {
--         enable = false,
--       },
--     },
--   },
-- })
