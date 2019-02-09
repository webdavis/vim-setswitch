" This script is sourced while inside the *.vim file with the Test_ functions. When the
" script is successful the .res file will be created. Errors are appended to
" ./logs/setswitch-<date>.log file.
"
" To execute only specific test functions, add a second argument. It will be matched
" against the names of the Test_ funtion. For example, to run Test_open_delay run the
" following command:
"
"   ./vim -u setup.vim -S runtest.vim test_channel.vim open_delay
"
" The output can be found in the 'messages' file.
"
" The test script may contain anything, only functions that start with 'Test_' are
" special. These will be invoked and should contain assert functions. For an example see
" test_assert.vim at: https://github.com/vim/vim/blob/master/src/testdir/test_assert.vim
"
" It is possible to source other files that contain 'Test_' functions. This can speed up
" testing, since Vim does not need to restart. But be careful that the tests do not
" interfere with each other.
"
" If an error cannot be detected properly with an assert function add the error to the
" v:errors list: call add(v:errors, 'test foo failed: Cannot find xyz')
"
" If preparation for each Test_ function is needed, define a SetUp function. It will be
" called before each Test_ function.
"
" If cleanup after each Test_ function is needed, define a TearDown function. It will be
" called after each Test_ function.
"
" When debugging a test it can be useful to add messages to v:errors:
" call add(v:errors, 'this happened')

" Common with all tests on all systems.
source setup.vim

" For consistency run all tests with 'nocompatible' set.
" This also enables use of line continuation.
set viminfo+=nviminfo

" Use utf-8 or latin1 by default, Instead of whatever the system default happens to be.
" Individual tests can overrule this at the top of the file.
if has('multi_byte')
    set encoding=utf-8
else
    set encoding=latin1
endif

" Avoid stopping at the 'hit enter' prompt
set nomore

" Output all messages in English.
language message C

" Always use forward slashes.
set shellslash

let s:srcdir = expand('%:p:h:h')

" Prepare for calling test_garbagecollect_now().
let v:testing = 1

" Support function: get the alloc ID by name.
function g:GetAllocId(name)
    execute 'split ' . s:srcdir . '/alloc.h'
    let top = search('typedef enum')
    if top ==? 0
        call add(v:errors, 'typedef not found in alloc.h')
    endif
    let lnum = search('aid_' . a:name . ',')
    if lnum ==? 0
        call add(v:errors, 'Alloc ID ' . a:name . ' not defined')
    endif
    close
    return lnum - top - 1
endfunction

function g:RunTheTest(test)
    echo 'Executing ' . a:test

    " Avoid stopping at the 'hit enter' prompt.
    set nomore

    " Avoid a three second wait when a message is about to be overwritten by the mode
    " message.
    set noshowmode

    " Clear any overrides.
    call test_override('ALL', 0)

    " Some tests wipe out buffers. To be consistent, always wipe out all buffers.
    %bwipe!

    " The test may change the current directory. Save and restore the directory after
    " executing the test.
    let s:save_cwd = getcwd()

    if exists("*SetUp")
        try
            call SetUp()
        catch
            call add(v:errors, 'Caught exception in SetUp() before ' . a:test . ': ' . v:exception . ' @ ' . v:throwpoint)
        endtry
    endif

    call add(s:messages, 'Executing ' . a:test)
    let s:done += 1

    " If the function begins with 'Test_nocatch_' then it handles errors itself. This
    " avoids skipping commands after the error.
    if a:test =~# 'Test_nocatch_'
        execute 'call ' . a:test
    else
        try
            let s:test = a:test
            autocmd VimLeavePre * call EarlyExit(s:test)
            execute 'call ' . a:test
            autocmd! VimLeavePre
        catch /^\cskipped/
            call add(s:messages, '    Skipped')
            call add(s:skipped, 'SKIPPED: ' . substitute(v:exception, '^\S*\s\+', '',  ''))
        catch
            call add(v:errors, 'Caught exception: ' . v:exception . ' @ ' . v:throwpoint)
        endtry
    endif

    " In case 'insertmode' was set and something went wrong, make sure it is
    " reset to avoid trouble with anything else.
    set noinsertmode

    if exists("*TearDown")
        try
            call TearDown()
        catch
            call add(v:errors, 'Caught exception in TearDown() after ' . a:test . ': ' . v:exception . ' @ ' . v:throwpoint)
        endtry
    endif

    " Clear any autocommands
    autocmd!

    " Close any extra tab pages and windows and make the current one not modified.
    while tabpagenr('$') >? 1
        quit!
    endwhile

    while 1
        let wincount = winnr('$')
        if wincount ==? 1
            break
        endif
        bwipe!
        if wincount ==? winnr('$')
            " Did not manage to close a window.
            only!
            break
        endif
    endwhile

    execute 'cd ' . s:save_cwd
endfunction

function g:PostTest()
    if len(v:errors) >? 0
        let s:fail += 1
        call add(s:errors, '  (X) ' . s:test . ':')
        call extend(s:errors, map(v:errors, {idx, val -> "    > " . v:val}))
        let v:errors = []
    endif
endfunction

function! s:Fnameescape(file) abort
    if exists('*fnameescape')
        return fnameescape(a:file)
    else
        return escape(a:file, " \t\n*?[{`$\\%#'\"|!<")
    endif
endfunction

function! s:Fnamemodify(file, modifier) abort
    return s:Fnameescape(fnamemodify(expand(a:file), a:modifier))
endfunction

" This function can be called by a test if it wants to abort testing.
function g:FinishTesting()
    call g:PostTest()

    " Don't write viminfo on exit.
    set viminfo=

    " Clean up files created by ./files/setup.vim
    call delete('XfakeHOME', 'rf')

    if s:fail ==? 0
        " Success, create the .res file so that make knows it's done.
        execute 'split ' . s:Fnamemodify(g:testname, ':r') . '.res'
        write
    endif

    if s:done ==? 0
        let message = 'No tests executed.'
    else
        let message = 'Success/Total: ' . (s:done - s:fail) . '/' . s:done
    endif
    echo message
    call add(s:messages, message)

    if s:fail >? 0
        let message = s:fail . ' FAILED:'
        echo message
        call add(s:messages, "")
        call add(s:messages, message)
        call extend(s:messages, s:errors)
    endif

    " Add SKIPPED messages.
    call extend(s:messages, s:skipped)

    " Append messages to the file 'messages'.
    split messages
    call append(line('$'), '')
    call append(line('$'), 'From ' . g:testname . ':')
    call append(line('$'), s:messages)
    write

    qall!
endfunction

" Source the test script. First grab the file name, in case the script navigates away.
" g:testname can be used by the tests.
let g:testname = expand('%')
let s:done = 0
let s:fail = 0
let s:errors = []
let s:messages = []
let s:skipped = []

try
    source %
catch
    let s:fail += 1
    call add(s:errors, 'Caught exception: ' . v:exception . ' @ ' . v:throwpoint)
endtry

" Locate Test_ functions and execute them.
redir @q
silent function /^Test_
redir END
let s:tests = split(substitute(@q, 'function \(\k*()\)', '\1', 'g'))

" If there is an extra argument filter the function names against it.
if argc() >? 1
    let s:tests = filter(s:tests, 'v:val =~# argv(1)')
endif

" Execute the tests in alphabetical order.
for s:test in sort(s:tests)
    " Silence, please!
    set belloff=all
    let prev_error = ''
    let total_errors = []
    let run_nr = 1

    call g:RunTheTest(s:test)

    call g:PostTest()
endfor

call g:FinishTesting()

" vim: shiftwidth=4 sts=4 expandtab
