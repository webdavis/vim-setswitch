" Maintainer: Stephen A. Davis <sdstephena@gmail.com>
" License: Unlicense
" Repository: vim-setswitch
" Description: consolidates visual noise to provide a cleaner workflow.

" See the following documentation:
"   :help compatible
"   :help vim7
"   https://semver.org/
let g:setswitch_version = '0.1.0'
if exists('g:loaded_setswitch') || &compatible || v:version <? 700
    finish
endif

if !has('autocmd')
    echoerr "Could not load " . expand('%') . ": editor has not been compiled with autocommand support."
    finish
endif

" Save the users compatible-options so that they may be restored later.
let s:save_cpoptions = &g:cpoptions
set cpoptions&vim
let g:loaded_setswitch = 1

if !exists('g:setswitch')
    let g:setswitch = {}
endif

function! s:Fnameescape(file)
    if exists('*fnameescape')
        return fnameescape(a:file)
    else
        return escape(a:file, " \t\n*?[{`$\\%#'\"|!<")
    endif
endfunction

function! s:Cache(file, key, value)
    let l:file = s:Fnameescape(a:file)
    call extend(g:setswitch, eval('{l:file: {},}'), 'keep')
    call extend(g:setswitch[eval('a:file')], eval('{a:key: a:value}'), 'force')
endfunction

function! s:CursorEnterBufferNormal(file)
    for l:option in get(g:, 'setswitch_hooks', [])
        if has_key(g:setswitch, a:file)
                \ && has_key(g:setswitch[a:file], l:option)
            execute printf("let &l:%s = %s", l:option, get(g:setswitch[a:file], l:option))
        elseif index(get(g:, eval(string('setswitch_no' . l:option . '_filetypes')), []), &filetype, 0, 1) >=? 0
                \ && type(eval('&' . l:option)) ==? type(v:t_number)
            execute printf("let &l:%s = 0", l:option)
        elseif index(get(g:, eval(string('setswitch_no' . l:option . '_filetypes')), []), &filetype, 0, 1) >=? 0
            execute printf("let &l:%s = ''", l:option)
        elseif index(get(g:, 'setswitch_toggle', []), l:option, 0, 1) >=? 0
            if exists(eval(string('g:setswitch_' . l:option)))
                execute printf("let &l:%s = %s", l:option, eval('g:setswitch_' . l:option))
            else
                execute printf("let &l:%s = &g:%s", l:option, l:option)
            endif
        endif
    endfor
endfunction

function! s:CursorWinLeaveNormal()
    for l:option in get(g:, 'setswitch_hooks', [])
        if index(get(g:, 'setswitch_toggle', []), l:option, 0, 1) >=? 0
                \ && !get(b:, eval(string('setswitch_' . l:option . '_frozen')), 0)
            execute printf("let &l:%s = 0", l:option)
        endif
    endfor
endfunction

function! s:CommandModeEnter()
    for l:option in get(g:, 'setswitch_cmdmode_toggle', [])
        if !get(b:, eval(string('setswitch_cmdmode_' . l:option . '_frozen')), 0)
            execute printf("let &l:%s = 0", l:option)
            execute 'redraw!'
        endif
    endfor
endfunction

augroup setswitch
    autocmd!
    autocmd FileType man,netrw,help call <SID>CursorEnterBufferNormal(expand('%:p'))
    autocmd FocusGained,WinEnter,InsertLeave,CmdwinEnter,CmdlineLeave *
        \ call <SID>CursorEnterBufferNormal(fnamemodify(expand('%'), ':p'))
    autocmd FocusLost,WinLeave,InsertEnter * call <SID>CursorWinLeaveNormal()

    " Listens for options being explicitly set and caches their values in a dictionary.
    execute 'autocmd OptionSet ' . join(get(g:, 'setswitch_hooks', []), ',')
        \ . ' :call <SID>Cache(fnamemodify(expand("%"), ":p"), expand("<amatch>"), eval("v:option_new"))'

    " Command mode is managed independently.
    autocmd CmdlineEnter * call <SID>CommandModeEnter()
augroup END

let &cpoptions = s:save_cpoptions
unlet! s:save_cpoptions
