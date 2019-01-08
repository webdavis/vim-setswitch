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

function! s:GetName()
    let l:name = substitute(substitute(l:option, '=.*', '', ''), 'no', '', '')
endfunction

function! s:Fnameescape(file)
    if exists('*fnameescape')
        return fnameescape(a:file)
    else
        return escape(a:file, " \t\n*?[{`$\\%#'\"|!<")
    endif
endfunction

function! s:Fnamemodify()
    return s:Fnameescape(fnamemodify(expand('%'), ':p'))
endfunction

function! s:SetLocal(option)
    execute printf('setlocal %s', a:option)
endfunction

" This will be called when entering a file. If one of the options in g:setswitch_hooks has
" been set in that file, it will override it's value in g:setswitch.
function! s:SetHook()
    let l:filename = s:Fnamemodify()
    if has_key(g:setswitch_dict, l:filename)
        for l:hook in items(get(g:setswitch_dict, l:filename))
            if type(l:hook[1]) ==? type(v:t_number)
                execute printf("let &l:%s = %s", l:hook[0], l:hook[1])
            else
                execute printf("let &l:%s = '%s'", l:hook[0], l:hook[1])
            endif
        endfor
    endif
endfunction

function! s:SwitchOn()
    if has_key(g:setswitch, &filetype)
        for l:option in g:setswitch[&filetype]
            call s:SetLocal(l:option)
        endfor
    elseif has_key(g:setswitch, 'all')
        for l:option in g:setswitch['all']
            call s:SetLocal(l:option)
        endfor
    endif

    call s:SetHook()
endfunction

function! s:StripOption(string)
        return substitute(substitute(a:string, '=.*', '', ''), 'no', '', '')
endfunction

function! s:GetValue(option)
        return eval('&l:' . substitute(a:option, '+\|-', '', ''))
endfunction

function! s:Turnoff(dictionary, key)
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

function! s:SwitchOff(dictionary)
    if has_key(a:dictionary, &filetype)
        call s:Turnoff(a:dictionary, &filetype)
    elseif has_key(a:dictionary, 'all')
        call s:Turnoff(a:dictionary, 'all')
    endif
endfunction

let g:setswitch = get(g:, 'setswitch', {})

let s:setswitch_insert = get(s:, 'setswitch_insert', {})

let g:setswitch_dict = get(g:, 'setswitch_dict', {})

augroup setswitch
    autocmd!
    autocmd FileType man,netrw,help call <SID>SwitchOn()
    autocmd FocusGained,WinEnter * call <SID>SwitchOn()
    autocmd FocusLost,WinLeave * call <SID>SwitchOff(g:setswitch)

    " Insert mode is managed independently.
    autocmd InsertEnter * call <SID>SwitchOff(g:setswitch_insert)
    autocmd InsertLeave * call <SID>SwitchOn()
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
            \ . ' :call <SID>Store(g:setswitch_dict, s:Fnamemodify(), expand("<amatch>"), eval("v:option_new"))'
augroup END

let &cpoptions = s:save_cpoptions
unlet! s:save_cpoptions
