" Maintainer: Stephen A. Davis <stephen@webdavis.io>
" License: Unlicense
" Repository: vim-setswitch
" Description: consolidates visual noise to provide a cleaner workflow.

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

function! s:get_key() abort
  return has_key(g:setswitch, s:filepath()) ? s:filepath() :
          \ has_key(g:setswitch, &filetype) ? &filetype :
          \ has_key(g:setswitch, &buftype) ? &buftype :
          \ has_key(g:setswitch, 'all') ? 'all' : 'BAD_KEY'
endfunction

function! s:set(option) abort
  execute 'setlocal ' . a:option
endfunction

function! s:base_option_name(option) abort
  return substitute(substitute(a:option, '=.*', '', ''), 'no', '', '')
endfunction

function! s:option_value(option) abort
  return eval('&l:' . substitute(a:option, '+\|-', '', ''))
endfunction

function! s:unset_value(value) abort
  return type(a:value) ==? type(v:t_number) ? 0 : "''"
endfunction

function! s:unset(option) abort
  " Strips down options to their base names and turns them off.
  execute printf("let &l:%s = %s", s:base_option_name(a:option), s:unset_value(s:option_value(s:base_option_name(a:option))))
endfunction

function! s:switch(...) abort
  try
    if a:0
      for l:option in a:1[s:get_key()]
        call s:unset(l:option)
      endfor
    else
      for l:option in g:setswitch[s:get_key()]
        call s:set(l:option)
      endfor
    endif
  catch /^Vim\%((\a\+)\)\=:E716/
  endtry
endfunction

function! s:focus_insert() abort
  call <SID>switch(g:setswitch_insert)
  let l:list1 = copy(g:setswitch[s:get_key()])
  let l:list2 = copy(g:setswitch_insert[s:get_key()])
  let l:intersection = filter(l:list1, 'index(l:list2, v:val) == -1')
  for l:option in l:intersection
    call s:set(l:option)
  endfor
endfunction

augroup setswitch
  autocmd!
  autocmd FileType man,netrw,help call <SID>switch()
  autocmd WinEnter * autocmd! FileType tagbar call <SID>switch()
  autocmd FocusGained * call eval('mode() ==# "i" ? <SID>focus_insert() : <SID>switch()')
  autocmd WinEnter,BufEnter * call <SID>switch()
  autocmd FocusLost,WinLeave * call <SID>switch(g:setswitch)

  " Insert mode is managed independently.
  autocmd InsertEnter * call <SID>switch(g:setswitch_insert)
  autocmd InsertLeave * call <SID>switch()

  " NERDTree support.
  autocmd User NERDTreeInit,NERDTreeNewRoot
          \ if exists('b:NERDTree.root.path.str') | call <SID>switch() | endif
augroup END

function! s:add_filekey_to_setswitch() abort
  call extend(g:setswitch, eval('{s:filepath(): [],}'), 'keep')
endfunction

function! s:filter_option(key) abort
  if match(g:setswitch[s:filepath()], "'.*".a:key.".*'")
    call filter(g:setswitch[s:filepath()], 'v:val !~# "'.a:key.'"')
  endif
endfunction

function! s:add_filevalue_to_setswitch(key, value) abort
  call s:filter_option(a:key)
  call extend(
          \ g:setswitch[s:filepath()],
          \ [eval('a:value || a:key ==# "colorcolumn" ? a:key : "no".a:key')
          \       .eval('a:key ==# "colorcolumn" ? "=".a:value : ""')],
          \ 'force')
endfunction

function! s:store(key, value) abort
  call s:add_filekey_to_setswitch()
  call s:add_filevalue_to_setswitch(a:key, a:value)
endfunction

function! s:has_option_set() abort
  return exists('g:setswitch_optionset') && !empty(g:setswitch_optionset)
endfunction

augroup setswitch_optionset
  autocmd!
  " Listens for the options in g:setswitch_optionset being explicitly set and caches
  " their values in a dictionary.
  if s:has_option_set()
    execute 'autocmd OptionSet '.join(g:setswitch_optionset, ',')
            \ .' :call <SID>store(expand("<amatch>"), eval("v:option_new"))'
  endif
augroup END

let &cpoptions = s:save_cpoptions
unlet! s:save_cpoptions


" vi:fdm=marker fdl=0 tw=90 sw=2 sts=2 ts=8:
