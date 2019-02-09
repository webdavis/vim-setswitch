" Maintainer: Stephen A. Davis <sdstephena@gmail.com>
" License: Unlicense
" Repository: vim-setswitch
" Description: consolidates visual noise to provide a cleaner workflow.

" See: https://semver.org/
let g:setswitch_version = '0.1.0'

if !has('autocmd')
    echoerr "Could not load " . expand('%') . ": editor has not been compiled with autocommand support."
    finish
endif

" See the following help files:
"   :help compatible
"   :help vim7
if exists('g:loaded_setswitch') || &compatible || v:version <? 700
    finish
endif

" Save the users compatible-options so that they may be restored later.
let s:save_cpoptions = &g:cpoptions
set cpoptions&vim
let g:loaded_setswitch = 1

function s:GetName() abort
    let l:name = substitute(substitute(l:option, '=.*', '', ''), 'no', '', '')
endfunction

function s:Fnameescape(file) abort
    if exists('*fnameescape')
        return fnameescape(a:file)
    else
        return escape(a:file, " \t\n*?[{`$\\%#'\"|!<")
    endif
endfunction

function s:Fnamemodify() abort
    return s:Fnameescape(fnamemodify(expand('%'), ':p'))
endfunction

function s:Set(option) abort
    execute printf('setlocal %s', a:option)
endfunction

" This will be called when entering a file. If one of the options in g:setswitch_hooks has
" been set in that file, it will override it's value in g:setswitch.
function s:SetHook() abort
    let l:filename = s:Fnamemodify()
    if has_key(s:setswitch_dict, l:filename)
        for l:hook in items(get(s:setswitch_dict, l:filename))
            if type(l:hook[1]) ==? type(v:t_number)
                execute printf("let &l:%s = %s", l:hook[0], l:hook[1])
            else
                execute printf("let &l:%s = '%s'", l:hook[0], l:hook[1])
            endif
        endfor
    endif
endfunction

function s:SwitchOn() abort
    if has_key(g:setswitch, &filetype)
        for l:option in g:setswitch[&filetype]
            call s:Set(l:option)
        endfor
    elseif has_key(g:setswitch, 'all')
        for l:option in g:setswitch['all']
            call s:Set(l:option)
        endfor
    endif

    if exists('g:setswitch_hooks') && !empty(g:setswitch_hooks)
        call s:SetHook()
    endif
endfunction

function s:StripOption(string) abort
        return substitute(substitute(a:string, '=.*', '', ''), 'no', '', '')
endfunction

function s:GetValue(option) abort
        return eval('&l:' . substitute(a:option, '+\|-', '', ''))
endfunction

" Strips down options to their base names and turns them off.
function s:Unset(dictionary, key) abort
    for l:option in a:dictionary[a:key]
        let l:name = s:StripOption(l:option)
        let l:value = s:GetValue(l:name)

        if type(l:value) ==? type(v:t_number)
            execute printf("let &l:%s = 0", l:name)
        else
            execute printf("let &l:%s = ''", l:name)
        endif
    endfor
endfunction

function s:SwitchOff(dictionary) abort
    if has_key(a:dictionary, &filetype)
        call s:Unset(a:dictionary, &filetype)
    elseif has_key(a:dictionary, 'all')
        call s:Unset(a:dictionary, 'all')
    endif
endfunction

let g:setswitch = get(g:, 'setswitch', {})

let g:setswitch_insert = get(g:, 'setswitch_insert', {})

let s:setswitch_dict = get(s:, 'setswitch_dict', {})

augroup setswitch
    autocmd!
    autocmd FileType man,netrw,help call <SID>SwitchOn()

    " NERDTree support.
    autocmd User NERDTreeInit,NERDTreeNewRoot
            \ if exists('b:NERDTree.root.path.str') | call <SID>SwitchOn() | endif

    autocmd WinEnter * autocmd! FileType tagbar call <SID>SwitchOn()

    autocmd FocusGained,WinEnter,BufEnter * call <SID>SwitchOn()
    autocmd FocusLost,WinLeave * call <SID>SwitchOff(g:setswitch)

    " Insert mode is managed independently.
    autocmd InsertEnter * call <SID>SwitchOff(g:setswitch_insert)
    autocmd InsertLeave * call <SID>SwitchOn()
augroup END

function s:Store(dictionary, file, key, value) abort
    call extend(eval('a:dictionary'), eval('{a:file: {},}'), 'keep')
    call extend(eval('a:dictionary[a:file]'), eval('{a:key: a:value}'), 'force')
endfunction

augroup setswitch_hooks
    autocmd!
    " Listens for the options in g:setswitch_hooks being explicitly set and caches their
    " values in a dictionary.
    if exists('g:setswitch_hooks') && !empty(g:setswitch_hooks)
        execute 'autocmd OptionSet ' . join(g:setswitch_hooks, ',')
                \ . ' :call <SID>Store(s:setswitch_dict, s:Fnamemodify(), expand("<amatch>"), eval("v:option_new"))'
    endif
augroup END

let &cpoptions = s:save_cpoptions
unlet! s:save_cpoptions
