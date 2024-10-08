set lbr
set textwidth=0
set wrapmargin=0
set wrap
set linebreak
" set columns=90

" Add code copied from tex filetype of vim sandwich plugin.
" if &compatible || exists('b:did_sandwich_tex_ftplugin') || get(g:, 'sandwich_no_tex_ftplugin', 0)
if exists('b:did_sandwich_tex_ftplugin') || get(g:, 'sandwich_no_tex_ftplugin', 0)
  finish
endif

runtime macros/sandwich/ftplugin/tex.vim

augroup sandwich-event-FileType
  autocmd!
  execute 'autocmd FileType markdown source ' . fnameescape(expand('<sfile>'))
augroup END

let b:did_sandwich_tex_ftplugin = 1
if !exists('b:undo_ftplugin')
  let b:undo_ftplugin = ''
else
  let b:undo_ftplugin .= ' | '
endif
let b:undo_ftplugin .= 'unlet b:did_sandwich_tex_ftplugin | call sandwich#util#ftrevert("tex")'

