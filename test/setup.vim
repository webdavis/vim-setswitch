" Only load this once. 1 only evaluates to true if Vim/Neovim has been compiled with the
" +eval feature.
if 1
    if exists('s:setup_loaded')
        finish
    endif
    let s:setup_loaded = 1
endif

" Settings for test script execution. Always use "sh", don't use the value of $SHELL.
set shell=sh

" Save this for tests that need to access files from the local environment.
let g:save_home = $HOME

" Always use utf-8, instead of depending on the system locale.
set encoding=utf-8

" Use safer defaults.
set backupdir=.
set undodir=.
set viewdir=.
set noswapfile
set nomore

" Align Neovim defaults to Vim.
set sidescroll=0
set directory=.
set undodir=.
set backspace=
set nrformats+=octal
set nohidden smarttab noautoindent noautoread complete-=i noruler noshowcmd
set listchars=eol:$
set fillchars=vert:\|,fold:-
set shortmess-=F

" Use default shell on Windows to avoid segfault, caused by TUI.
if has('win32')
    let $SHELL = ''
    let $TERM = ''
    let &shell = empty($COMSPEC) ? exepath('cmd.exe') : $COMSPEC
    set shellcmdflag=/s/c shellxquote=\" shellredir=>%s\ 2>&1
    let &shellpipe = &shellredir
endif

filetype plugin indent on

" Make sure 'runtimepath' and 'packpath' do not include $HOME unless a Docker environment
" is detected.
if empty(globpath('/', '.dockerenv'))
    if 1
        let $HISTFILE = ""

        " Make sure $HOME does not get read or written to. It must exist, GNOME tries to
        " create $HOME/.gnome2
        let $HOME = getcwd() . '/XfakeHOME'
        if !isdirectory($HOME)
            call mkdir($HOME)
            call mkdir($HOME . '/.vim')
        endif
    endif
    set runtimepath=$VIM/vimfiles,$VIM/vimfiles/after,../,$HOME/.vim
else
    set runtimepath=$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.vim
    " Note: Travis CI will build the docker container and run CI tests every push.
    call plug#begin('~/.vim/plugged')

    " For testing some plugin compatibility.
    Plug 'scrooloose/nerdtree'
    Plug 'majutsushi/tagbar'
    Plug 'ludovicchabant/vim-gutentags'

    call plug#end()
endif

if has('packages')
    let &packpath = &runtimepath
endif

" Prevent Neovim log from writing to stderr.
let $VIM_LOG_FILE = exists($VIM_LOG_FILE) ? $VIM_LOG_FILE : 'setswitch.log'
let g:log = $VIM_LOG_FILE

" View man pages using :Man command.
runtime! ftplugin/man.vim

" vim: filetype=vim shiftwidth=4 softtabstop=4 expandtab
