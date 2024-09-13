local use_executable = true

function ToggleTexlabExecutable()
  use_executable = not use_executable
  
  local executable
  local args
  
  if use_executable then
    executable = '/Applications/Skim.app/Contents/SharedSupport/displayline'
    args = { '-g', '%l', '%p', '%f' }
    print("texlabconfig forwardSearch enabled")
  else
    -- Set to nil to unset the executable
    executable = nil
    args = nil
    print("nvim-texlabconfig disabled")
  end
  
  -- Update the Texlab configuration
  local texlab_config = require('lspconfig').texlab.manager.config
  texlab_config.settings.texlab.forwardSearch.executable = executable
  texlab_config.settings.texlab.forwardSearch.args = args
  
  -- Notify the server of the configuration change
  vim.lsp.buf_notify(0, 'workspace/didChangeConfiguration', {settings = texlab_config.settings})
end

return {
  {
    'f3fora/nvim-texlabconfig',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      local lspconfig = require 'lspconfig'
      -- need to remove the -g to get the viewer to show up. Otherwise open manually
      local executable = '/Applications/Skim.app/Contents/SharedSupport/displayline'
      local args = { '-g', '%l', '%p', '%f' }
      -- local args = {"%l", "%p", "%f" }

      lspconfig.texlab.setup {
        settings = {
          texlab = {
            -- auxDirectory = ".",
            -- bibtexFormatter = "texlab",
            build = {
              onSave = true,
              -- forwardSearchAfter = false,
              forwardSearchAfter = true,
              -- args = { "-pdf", "-pvc", "-interaction=nonstopmode", "-synctex=1", "%f" },
              -- args = { "-pdf", "-interaction=nonstopmode", "-synctex=0", "%f" },
            },
            forwardSearch = {
              -- add the line
              executable = executable,
              args = args,
            },
            latexFormatter = 'latexindent',
            latexindent = {
              modifyLineBreaks = false,
            },
            chktex = {
              onEdit = false,
              onOpenAndSave = false,
            },
            diagnosticsDelay = 300,
            formatterLineLength = 80,
          },
        },
      }
    end,
    ft = { 'tex', 'bib' }, -- Lazy-load on filetype
    -- build = "go build",
    build = 'go build -o ~/.local/bin/', -- if e.g. ~/.bin/ is in $PATH
  },
  {
    'lervag/vimtex', -- vimtex provides the conceal and checks in math for tex snippets.
    enabled = true,
    -- event = "VeryLazy",
    -- event = 'BufEnter *.tex *.md',
    -- tag= "v1.6",
    ft = {'tex', 'markdown'},
    keys = {
      { '<leader>vc', '<cmd>VimtexCompile<CR>', desc = 'Compile tex document' },
      { '<leader>vt', '<cmd>VimtexTocOpen<CR>', desc = 'Latex Table of Contents' },
    },
    config = function()
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 0 -- do not change focus
      -- vim.g.vimtex_syntax_custom_cmds = {
      --   {name = 'R', mathmode = 1, concealchar = 'ℝ'},
      -- }

      vim.cmd [[let g:vimtex_syntax_custom_cmds = [
          \ {'name': 'R', 'mathmode': 1, 'concealchar': 'ℝ'},
          \]
          ]]
      vim.cmd [[
  nnoremap <leader>vv :call vimtex#fzf#run()<cr>
  syntax enable
  ]]

      vim.cmd [[let g:vimtex_compiler_latexmk = {
        \ 'aux_dir' : '',
        \ 'out_dir' : '',
        \ 'callback' : 1,
        \ 'continuous' : 1,
        \ 'executable' : 'latexmk',
        \ 'hooks' : [],
        \ 'options' : [
        \   '-shell-escape',
        \   '-verbose',
        \   '-file-line-error',
        \   '-synctex=1',
        \   '-interaction=nonstopmode',
        \ ],
        \}
]]
    end,
  },
}
