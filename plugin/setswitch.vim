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

function! s:Fnameescape(file)
    if exists('*fnameescape')
        return fnameescape(a:file)
    else
        return escape(a:file, " \t\n*?[{`$\\%#'\"|!<")
    endif
endfunction

let s:setswitch_filetype = get(s:, 'setswitch_filetype', {})

function! s:Cache(dictionary, file, key, value)
    call extend(eval('a:dictionary'), eval('{a:file: {},}'), 'keep')
    call extend(eval('a:dictionary[a:file]'), eval('{a:key: a:value}'), 'force')
endfunction

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
        elseif has_key(g:setswitch_filetype, &filetype)
            for l:option in g:setswitch_filetype[&filetype]
                execute printf('set %s', l:option)
            endfor
        endif
endfunction

let s:setswitch = get(s:, 'setswitch', {})

function! s:CursorLeave()
    for l:option in get(g:, 'setswitch_toggle', [])
        " Without this, multi-valued options like colorcolumn won't be able to be reset to multiple values.
        call s:Cache(s:setswitch, s:Fnameescape(fnamemodify(expand("%"), ":p")), l:option, eval('&l:' . l:option))
        execute printf("let &l:%s = 0", l:option)
    endfor
endfunction

let s:setswitch_insert = get(s:, 'setswitch_insert', {})

" Options added to g:setswitch_insert_toggle will be switched off.
function! s:InsertEnter()
    for l:option in get(g:, 'setswitch_insert_toggle', [])
        call s:Cache(s:setswitch_insert, s:Fnameescape(fnamemodify(expand("%"), ":p")), l:option, eval('&l:' . l:option))

        if type(eval('&l:' . l:option)) ==? type(v:t_number)
            execute printf("let &l:%s = 0", l:option)
        else
            execute printf("let &l:%s = ''", l:option)
        endif
    endfor
endfunction

let s:setswitch_command = get(s:, 'setswitch_command', {})

" Options added to g:setswitch_command_toggle will be switched off.
function! s:CmdlineEnter()
    for l:option in get(g:, 'setswitch_command_toggle', [])
        call s:Cache(s:setswitch_command, s:Fnameescape(fnamemodify(expand("%"), ":p")), l:option, eval('&l:' . l:option))

        if type(eval('&l:' . l:option)) ==? type(v:t_number)
            execute printf("let &l:%s = 0", l:option)
        else
            execute printf("let &l:%s = ''", l:option)
        endif
        execute 'redraw'
    endfor
endfunction

augroup setswitch
    autocmd!
    autocmd FileType man,netrw,help call <SID>WindowEnter(s:setswitch, s:Fnameescape(fnamemodify(expand('%'), ':p')))
    autocmd FocusGained,WinEnter * call <SID>WindowEnter(s:setswitch, s:Fnameescape(fnamemodify(expand('%'), ':p')))
    autocmd FocusLost,WinLeave * call <SID>CursorLeave()

    " Insert mode is managed independently.
    autocmd InsertEnter * call <SID>InsertEnter()
    autocmd InsertLeave * call <SID>WindowEnter(s:setswitch_insert, s:Fnameescape(fnamemodify(expand('%'), ':p')))

    " Command-line mode is managed independently.
    autocmd CmdlineEnter * call <SID>CmdlineEnter()
    autocmd CmdlineLeave * call <SID>WindowEnter(s:setswitch_command, s:Fnameescape(fnamemodify(expand('%'), ':p')))

    " Listens for the options in g:setswitch_hooks being explicitly set and caches their
    " values in a dictionary.
    execute 'autocmd OptionSet ' . join(get(g:, 'setswitch_hooks', []), ',')
        \ . ' :call <SID>Cache(s:setswitch, s:Fnameescape(fnamemodify(expand("%"), ":p")), expand("<amatch>"), eval("v:option_new"))'
augroup END

let &cpoptions = s:save_cpoptions
unlet! s:save_cpoptions
