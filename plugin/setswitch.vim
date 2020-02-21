" Maintainer: Stephen A. Davis <stephen@webdavis.io>
" License: Unlicense
" Repository: vim-setswitch
" Description: consolidates visual noise to provide a cleaner workflow.

" TODO: add support for vim terminal.
" TODO: fix colorcolumn failure (first reproduce bug, and then fix).
" TODO: fix help window toggling number off when leaving.

" See: https://semver.org/
let g:setswitch_version = '0.1.0'

if !has('autocmd')
  echoerr "Could not load ".expand('%:t').": editor has not been compiled with autocmd support."
  finish
endif

if exists('g:loaded_setswitch') || &compatible || v:version <? 700
  finish
endif

" Save the users compatible-options so that they may be restored later.
let s:save_cpoptions = &g:cpoptions
set cpoptions&vim
let g:loaded_setswitch = 1

let g:setswitch = get(g:, 'setswitch', {})
let g:setswitch_insert = get(g:, 'setswitch_insert', {})
let g:setswitch_optionset = get(g:, 'setswitch_optionset', {})

function! s:fnameescape(file) abort
  return exists('*fnameescape') ? fnameescape(a:file) : escape(a:file, " \t\n*?[{`$\\%#'\"|!<")
endfunction

function! s:filepath() abort
  return s:fnameescape(fnamemodify(expand('%'), ':p'))
endfunction

function! s:getValueLiteral(value) abort
  return type(a:value) ==? type(v:t_number) ? a:value : \'a:value\'
endfunction

" This will be called when entering a file. If one of the options in g:setswitch_optionset
" has been set in that file, it will override it's value in g:setswitch.
function! s:setHook() abort
  try
    for l:hook in items(get(g:setswitch_optionset, s:filepath()))
      execute printf("let &l:%s = %s", l:hook[0], s:getValueLiteral(l:hook[1]))
    endfor
  catch /^Vim\%((\a\+)\)\=:E123/
    return
  endtry
endfunction

function! s:getSetswitchKey() abort
  return has_key(g:setswitch, s:filepath()) ? s:filepath() :
          \ has_key(g:setswitch, &filetype) ? &filetype :
          \ has_key(g:setswitch, &buftype) ? &buftype :
          \ has_key(g:setswitch, 'all') ? 'all' : 'BAD_KEY'
endfunction

function! s:set(option) abort
  execute 'setlocal ' . a:option
endfunction

function! s:baseOptionName(option) abort
  return substitute(substitute(a:option, '=.*', '', ''), 'no', '', '')
endfunction

function! s:optionValue(option) abort
  return eval('&l:' . substitute(a:option, '+\|-', '', ''))
endfunction

function! s:unsetValue(value) abort
  return type(a:value) ==? type(v:t_number) ? 0 : "''"
endfunction

function! s:unset(option) abort
  " Strips down options to their base names and turns them off.
  execute printf("let &l:%s = %s", s:baseOptionName(a:option), s:unsetValue(s:optionValue(s:baseOptionName(a:option))))
endfunction

function! s:switch(...) abort
  try
    if a:0
      for l:option in a:1[s:getSetswitchKey()]
        call s:unset(l:option)
      endfor
    else
      for l:option in g:setswitch[s:getSetswitchKey()]
        call s:set(l:option)
      endfor
    endif
  catch /^Vim\%((\a\+)\)\=:E716/
  endtry
endfunction

augroup setswitch
  autocmd!
  autocmd FileType man,netrw,help call <SID>switch()
  autocmd WinEnter * autocmd! FileType tagbar call <SID>switch()
  autocmd FocusGained,WinEnter,BufEnter * call <SID>switch()
  autocmd FocusLost,WinLeave * call <SID>switch(g:setswitch)

  " Insert mode is managed independently.
  autocmd InsertEnter * call <SID>switch(g:setswitch_insert)
  autocmd InsertLeave * call <SID>switch()

  " NERDTree support.
  autocmd User NERDTreeInit,NERDTreeNewRoot
          \ if exists('b:NERDTree.root.path.str') | call <SID>switch() | endif
augroup END

function! s:addFileKeyToSetswitch() abort
  call extend(g:setswitch, eval('{s:filepath(): [],}'), 'keep')
endfunction

function! s:filterOption(key) abort
  if match(g:setswitch[s:filepath()], "'.*".a:key.".*'")
    call filter(g:setswitch[s:filepath()], 'v:val !~# "'.a:key.'"')
  endif
endfunction

function! s:addFileValueToSetswitch(key, value) abort
  call s:filterOption(a:key)
  call extend(
          \ g:setswitch[s:filepath()],
          \ [eval('a:value || a:key ==# "colorcolumn" ? a:key : "no".a:key')
          \       .eval('a:key ==# "colorcolumn" ? "=".a:value : ""')],
          \ 'force')
endfunction

function! s:store(key, value) abort
  call s:addFileKeyToSetswitch()
  call s:addFileValueToSetswitch(a:key, a:value)
endfunction

function! s:hasOptionSet() abort
  return exists('g:setswitch_optionset') && !empty(g:setswitch_optionset)
endfunction

augroup setswitch_optionset
  autocmd!
  " Listens for the options in g:setswitch_optionset being explicitly set and caches
  " their values in a dictionary.
  if s:hasOptionSet()
    execute 'autocmd OptionSet '.join(g:setswitch_optionset, ',')
            \ .' :call <SID>store(expand("<amatch>"), eval("v:option_new"))'
  endif
augroup END

let &cpoptions = s:save_cpoptions
unlet! s:save_cpoptions


" vi:fdm=marker fdl=0 tw=90 sw=2 sts=2 ts=8:
