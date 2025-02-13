set lbr
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

" Set textwidth for Markdown files
" setlocal textwidth=80

" Hi Claude. I would like the textwidth formatting to avoid breaking within a
" math environment $...$ in markdown, but to still break at the end of it,
" considering it as a single block. Note that the cursor will be at the end of
" the line when formatting occurs, not in the math environment, and the
" formatter will then try to break within the math environment.
" setlocal formatexpr=MarkdownFormat()
"
" function! MarkdownFormat()
"     if mode() =~# '[iR]'
"         return 1
"     endif
"
"     let l:line = getline('.')
"     
"     " Check if the line contains math environments
"     let l:start = 0
"     let l:formatted_line = ''
"     
"     while l:start < strlen(l:line)
"         let l:math_start = match(l:line, '\$', l:start)
"         
"         if l:math_start == -1
"             " No more math environments, format normally
"             let l:formatted_line .= l:line[l:start:]
"             break
"         endif
"         
"         " Add text before math environment
"         let l:formatted_line .= l:line[l:start:l:math_start-1]
"         
"         " Find closing $
"         let l:math_end = match(l:line, '\$', l:math_start + 1)
"         if l:math_end == -1
"             " Unclosed math environment, treat rest of line normally
"             let l:formatted_line .= l:line[l:math_start:]
"             break
"         endif
"         
"         " Add entire math environment as one block
"         let l:formatted_line .= l:line[l:math_start:l:math_end]
"         
"         let l:start = l:math_end + 1
"     endwhile
"     
"     " Replace line with formatted version
"     call setline('.', l:formatted_line)
"     
"     " Let Vim handle the actual line breaking
"     return 1
" endfunction
" "Hey Claude, the above works! Can you modify it so that wikilinks [[...]] are
" "also an atomic unit in the same way?
