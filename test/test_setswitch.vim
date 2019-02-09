" Base tests for setswitch.vim.

func TearDown()
    " Runs garbage collection after every test.
    call test_garbagecollect_now()
endfunc

function Test_SwitchOn_option_string()
    let l:filename = 'testfile'
    execute 'split ' . l:filename
    set colorcolumn=
    let g:setswitch = {'all': ['colorcolumn=91']}
    wincmd w
    call assert_equal('91', &colorcolumn)
endfunction

" function Test_WinLeave_option()
"     set colorcolumn=91
"     let g:setswitch = {'all': ['colorcolumn=91']}
"
"     let l:filename = bufname('%')
"     augroup test_windowleave_option
"         execute 'autocmd WinLeave ' . expand('<amatch>') . ' let g:colorcolumn_value = ' . &colorcolumn
"     augroup END
"     execute 'split ' . l:filename
"     assert_equal('', g:colorcolumn_value)
" endfunction
