setswitch.vim - UNSTABLE
=============

_setswitch.vim: a user extensible plugin that adds window local capabilities to all
options in Vim._

setswitch is probably the most useful plugin I've created. I wouldn't want to use Vim
without it. Here's why:

- setswitch allows you to run settings upon entering a window, and turn them off when you
  leave the window. That means even settings like `hlsearch` can be window local with
  setswitch.
- setswitch is only limited to your imagination. It works with _any setting_.

## Install

To install setswitch use any one of your favorite plugin managers.

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'webdavis/vim-denver'
```

### Manual Install

Install it in Vim 8.0, like so:

    mkdir -p ~/.vim/pack/start
    git clone git@github.com:webdavis/vim-setswitch.git ~/.vim/pack/start/vim-setswitch

## Configuration

setswitch is user extensible, meaning that the following settings should take any option
available in Vim/Neovim.

### g:setswitch

g:setswitch is a **Dictionary** of the form:

```vim
g:setswitch = { filetype: ['option=value', 'option=value', 'option=value'...], }
```

Put this in your `~/.vimrc`, to set options when the cursor enters certain filetypes.
You're probably wondering why this is needed when the `~/.vim/ftplugin` directory exists.
Setswitch specifically toggles the settings you put in it off when leaving the window, and
then back on when entering.

Setswitch will run `set` on whatever `{option=values}` you put `g:setswitch` if the
filetype entry exists. If the filetype doesn't have an entry then the options in the
`{'all'}` entry are `set`.

```vim
let g:setswitch = {
      \ { 'all': ['colorcolumn=+1', 'cursorline', 'cursorcolumn', 'relativenumber'] },
      \ { 'netrw': ['colorcolumn=', 'nocursorline', 'nocursorcolumn'] },
      \ { 'man': ['colorcolumn=', 'nocursorline', 'nocursorcolumn'] },
      \ { 'help': ['colorcolumn=', 'nocursorline', 'nocursorcolumn'] },
      \ { 'gitcommit': ['colorcolumn=+1,51', 'cursorline', 'cursorcolumn', 'relativenumber'] },
      \ }
```

Setswitch will run `set colorcolumn=+1 cursorline cursorcolumn relativenumber` on all
filetypes except the `netrw`, `man`, `help`, and `gitcommit` filetypes. For those
filetypes their respective entries will be set.

#### Tagbar

Tagbar is supported. To enable it add the following entry to your `g:setswitch`
dictionary.

```vim
let g:setswitch = {
        \ 'tagbar': ['colorcolumn=', 'nocursorline', 'nocursorcolumn', 'number', 'relativenumber'],
        \ }
```

#### NERDTree

NERDTree is supported. To enable it add the following entry to your `g:setswitch`
dictionary.

```vim
let g:setswitch = {
        \ 'nerdtree': ['colorcolumn=', 'nocursorline', 'nocursorcolumn', 'number', 'relativenumber'],
        \ }
```

### g:setswitch_insert

Insert mode has it's own controller variable so that you can do unique things with it. It
works a little different than `g:setswitch`. It has the form:

```vim
g:setswitch_insert = { filetype: ['option', 'option', 'option'...], }
```

Set the following in your `~/.vimrc`, to instruct setswitch to toggle these settings off
when entering insert mode.

```vim
" Toggle these settings upon entering and exiting insert mode.
let g:setswitch_insert = {
        \ 'all': ['cursorline', 'cursorcolumn', 'relativenumber'],
        \ }
```

Setswitch will run `set nocursorline nocursorcolumn norelativenumber` on all filetypes
when entering insert mode.

### g:setswitch_hooks

`g:setswitch_hooks` takes a **List** of options instructing setswitch to use the
`OptionSet` autocommand to listen for these options being set. If they are set then
setswitch will store the option and value of the option in the dictionary
`s:setswitch_dict`, by file name.

Put this in your `~/.vimrc` to instruct setswitch to store the values of the following
options whenever the user sets them. Whenever the cursor enters the window where these
were unset, setswitch will set these values even if the option only has a global scope and
was unset in another window. This pairs nicely with Tpope's vim-unimpaired plugin:
https://github.com/tpope/vim-unimpaired

```vim
let g:setswitch_hooks = ['cursorline', 'cursorcolumn', 'relativenumber', 'wrap', 'hlsearch', 'colorcolumn']
```

---

> Note: this feature will be disabled if `g:setswitch_hooks` is empty or doesn't exist:

---

## Contributing

See [CONTRIBUTING.md](/CONTRIBUTING.md).

## License

This plugin is distributed under the same terms as Vim. See `:help license`

## Author information

This project is maintained by Stephen A. Davis.

GitHub: [webdavis](https://github.com/webdavis)
