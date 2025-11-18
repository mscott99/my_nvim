-- This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
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
-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
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
local capabilities = vim.lsp.protocol.make_client_capabilities()
local servers = {
  pyright = {},
  julials = {},
  -- typst_lsp = {
  -- settings = {
  -- exportPdf = 'never',
  -- },
  -- },
  ts_ls = {},
  ltex = {
    ltex = {
      enabled = true,
      checkFrequency = 'save',
      language = 'en-US',
      dictionary = {
        ['en-US'] = {
          'infimum',
          'supremum',
          'WLOG',
          'normals',
          'summand',
          'preconditioner',
          'semidefinite',
          'nonsmooth',
          'subdifferential',
          'subdifferentials',
          'subgradient',
          'subgradients',
          'Longform',
          'Zotero',
          'url',
          'TODO',
          'Hadamard',
          'argmax',
          'pushforward',
          'coherences',
          'HardTanh',
          'MaxPool',
          'piecewise-linear',
          'subsampled',
          'neurips',
          'piecewise',
          'Piecewise',
          'sqrt',
          'txt',
          'std',
          'De-biasing',
          'de-biased',
          'monotonicity',
          'Monotonicity',
          'Yilmaz',
          'Christoffel',
          'isometries',
          'orthogonalization',
          'ReLU',
          'logarithmically',
          'Adcock',
          'pseudoinverse',
          'iff',
          'orthant',
          'subsample',
          'Ozgur',
          'Yaniv',
          'Haar',
          'litreview',
          'longform',
          'wikilink',
          'wikilinks',
          'chatgpt',
        },
      },
      additionalRules = {
        enablePickyRules = true, -- only at the end
        languageModel = '/Users/matthewscott/.config/my_nvim/data/ngrams/',
      },
      disabledRules = {
        ['en-US'] = {
          'UPPERCASE_SENTENCE_START',
          'GERMAN_QUOTES',
          'EN_UNPAIRED_BRACKETS',
          'UNLIKELY_OPENING_PUNCTUATION',
          'COMMA_PARENTHESIS_WHITESPACE',
          'EN_A_VS_AN',
          'EN_QUOTES',
          'CONFUSION_RULE_BOUND_BOND',
          'TOO_LONG_SENTENCE',
          'SO_AS_TO',
          'PUNCTUATION_PARAGRAPH_END',
          'CONSEQUENCES_OF_FOR',
        },
      },
    },
  },
}
-- Setup neovim lua configuration
-- require('neodev').setup()
-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}
-- Now manually configure each server (replaces setup_handlers)
for server_name, server_settings in pairs(servers) do
  -- Default setup for all servers
  local server_config = {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = server_settings or {},
    filetypes = (server_settings or {}).filetypes,
  }
  -- Custom setup for ltex to suppress status messages
  if server_name == "ltex" then
    server_config.handlers = {
      ["$/progress"] = function(_, result, ctx)
        -- Suppress progress messages containing "Checking document"
        if result.value.message and result.value.message:match("Checking document") then
          return -- Ignore the message
        end
        -- Optionally, pass other progress messages to default handler
        -- vim.notify(result.value.message, vim.log.levels.INFO)
      end,
      ["window/showMessage"] = function(_, result, _)
        -- Suppress showMessage notifications containing "Checking document"
        if result.message:match("Checking document") then
          return -- Ignore the message
        end
        -- vim.notify(result.message, vim.log.levels.INFO)
      end,
    }
  end
  -- Apply the configuration
  vim.lsp.config(server_name, server_config)
end
vim.lsp.config('sourcekit', {
  capabilities = vim.tbl_deep_extend('force', capabilities, {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  }),
  on_attach = on_attach,
})
vim.lsp.config('mojo', {
  capabilities = capabilities,
  on_attach = on_attach,
})
