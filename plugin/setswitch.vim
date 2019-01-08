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

function! s:WindowEnter(dictionary, file)
    if has_key(eval('a:dictionary'), a:file)
        for l:option in items(get(eval('a:dictionary'), a:file))

            " Note: the single quotes around %s are important.
            if type(l:option[1]) ==? type(v:t_number)
                execute printf("let &l:%s = %s", l:option[0], l:option[1])
            else
                execute printf("let &l:%s = '%s'", l:option[0], l:option[1])
            endif
        endfor
    else
        if !has_key(g:setswitch, &filetype)
            if has_key(g:setswitch, 'all')
                for l:option in g:setswitch['all']
                    execute printf('setlocal %s', l:option)
                endfor
            endif
        else
            for l:option in g:setswitch[&filetype]
                execute printf('setlocal %s', l:option)
            endfor
        endif
    endif
endfunction

function! s:TurnOff(dictionary)
    if !has_key(a:dictionary, &filetype)
        if has_key(a:dictionary, 'all')
            for l:option in a:dictionary['all']
                let l:name = substitute(substitute(l:option, '=.*', '', ''), 'no', '', '')
                let l:value = eval('&l:' . substitute(l:name, '+\|-', '', ''))

                if type(l:value) ==? type(v:t_number)
                    execute printf("let &l:%s = 0", l:name)
                else
                    execute printf("let &l:%s = ''", l:name)
                endif
            endfor
        endif
    else
        for l:option in a:dictionary[&filetype]
            let l:name = substitute(substitute(l:option, '=.*', '', ''), 'no', '', '')
            let l:value = eval('&l:' . substitute(l:name, '+\|-', '', ''))

            if type(l:value) ==? type(v:t_number)
                execute printf("let &l:%s = 0", l:name)
            else
                execute printf("let &l:%s = ''", l:name)
            endif
        endfor
    endif
endfunction

function! s:Fnameescape(file)
    if exists('*fnameescape')
        return fnameescape(a:file)
    else
        return escape(a:file, " \t\n*?[{`$\\%#'\"|!<")
    endif
endfunction

let g:setswitch = get(g:, 'setswitch', {})

let s:setswitch_insert = get(s:, 'setswitch_insert', {})

let s:setswitch_dict = get(s:, 'setswitch_dict', {})

augroup setswitch
    autocmd!
    autocmd FileType man,netrw,help call <SID>WindowEnter(s:setswitch_dict, s:Fnameescape(fnamemodify(expand('%'), ':p')))
    autocmd FocusGained,WinEnter * call <SID>WindowEnter(s:setswitch_dict, s:Fnameescape(fnamemodify(expand('%'), ':p')))
    autocmd FocusLost,WinLeave * call <SID>TurnOff(g:setswitch)

    " Insert mode is managed independently.
    autocmd InsertEnter * call <SID>TurnOff(g:setswitch_insert)
    autocmd InsertLeave * call <SID>WindowEnter(s:setswitch_insert, s:Fnameescape(fnamemodify(expand('%'), ':p')))
augroup END

function! s:Store(dictionary, file, key, value)
    call extend(eval('a:dictionary'), eval('{a:file: {},}'), 'keep')
    call extend(eval('a:dictionary[a:file]'), eval('{a:key: a:value}'), 'force')
endfunction

augroup setswitch_hooks
    autocmd!
    " Listens for the options in g:setswitch_hooks being explicitly set and caches their
    " values in a dictionary.
    execute 'autocmd OptionSet ' . join(get(g:, 'setswitch_hooks', []), ',')
            \ . ' :call <SID>Store(s:setswitch_dict, s:Fnameescape(fnamemodify(expand("%"), ":p")), expand("<amatch>"), eval("v:option_new"))'
augroup END

let &cpoptions = s:save_cpoptions
unlet! s:save_cpoptions
