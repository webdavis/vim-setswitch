setswitch.vim
=============

_setswitch.vim: a user extensible plugin that adds window local capabilities to all
options in Vim._

setswitch is probably the most useful plugin I've created. I literally wouldn't want to
use Vim without it. Here's why:

- setswitch makes all settings window local. That means even settings like `hlsearch` are
  window local with setswitch.
- setswitch can enable settings for the active window, while disabling settings for the
  inactive windows.
- setswitch is only limited to your imagination. It works with _any setting_.

## Install

To install setswitch use any one of your favorite plugin managers.

#### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'webdavis/vim-denver'
```

#### Manual Install

Install it in Vim 8.0, like so:

    mkdir -p ~/.vim/pack/start
    git clone git@github.com:webdavis/vim-setswitch.git ~/.vim/pack/start/vim-setswitch

## Configuration

setswitch is user extensible, meaning that the following settings should take any option
available in Vim/Neovim.

#### g:setswitch_toggle

`g:setswitch_toggle` takes a **List** of options as an argument. It turns these options on
upon the cursor entering a window, and off upon the cursor exiting the window.

For example, putting the following in your `~/.vimrc` instructs setswitch to toggle these
setting when entering/exiting the window.

```vim
let g:setswitch_toggle = ['cursorline', 'cursorcolumn', 'colorcolumn', 'relativenumber']

" Or you can get creative.
let g:setswitch_toggle = ['cursorline', 'nocursorcolumn', 'nocolorcolumn', 'relativenumber']
```

#### g:setswitch_insert_toggle

Insert mode has it's own controller variable so that you can do unique things with it.
`g:setswitch_insert_toggle` takes a **List** of options as an argument and turns these
options off upon entering the insert mode, and on upon exiting insert mode.

The following setting turns `relativenumber`, `cursorline`, and `cursorcolumn` off when
entering the insert mode.

```vim
let g:setswitch_insert_toggle = ['relativenumber', 'cursorline', 'cursorcolumn']
```

#### g:setswitch_command_toggle

The command-line has it's own controller variable so that you can do unique things with
it. `g:setswitch_command_toggle` takes a **List** of options as an argument and turns
these options off upon entering the command-line, and on upon exiting the command-line.

The following setting turns `relativenumber` and `hlsearch` off when entering the
command-line.

```vim
let g:setswitch_command_toggle = ['relativenumber', 'cursorline', 'cursorcolumn', 'colorcolumn']
```

#### g:setswitch_hooks

`g:setswitch_hooks` takes a **List** of options instructing setswitch to listen for these
options being set using the `OptionSet` autocommand. If they are set then setswitch will
store the option and value of the option in the dictionary `s:setswitch`, by file name.

Put this in your `~/.vimrc` to instruct setswitch to store the values of the following
options whenever the user sets them. Whenever the cursor enters the window where these are
set, setswitch will set these values even if they were globally set in another window.
This pairs nicely with Tpope's vim-unimpaired plugin: https://github.com/tpope/vim-unimpaired

```vim
let g:setswitch_hooks = ['cursorline', 'cursorcolumn', 'relativenumber', 'wrap', 'hlsearch', 'colorcolumn']
```

#### g:setswitch_exclude

g:setswitch_exclude is a **Dictionary** of the form:

```vim
g:setswitch_exclude = { filetype: ['option', 'option', 'option'...], }
```

Put this in your `~/.vimrc`, to set options when the cursor enters certain filetypes.
You're probably wondering why this is needed when the `~/.vim/ftplugin` directory exists.
It's to prevent setswitch from activating options when you leave a window of a certain
filetype without closing the window and then reenter it later. Unfortunately this is the
best we can manage with Vim's present capabilities.

Here is a useful example:

```vim
let g:setswitch_exclude = {
    \ { 'netrw': ['colorcolumn=', 'nocursorline', 'nocursorcolumn'] },
    \ { 'man': ['colorcolumn=', 'nocursorline', 'nocursorcolumn'] },
    \ { 'help': ['colorcolumn=', 'nocursorline', 'nocursorcolumn'] },
    \ }
```

Setswitch will set these options when entering the corresponding `netrw`, `man`, and
`help` filetypes.

## Contributing

See [CONTRIBUTING.md](/CONTRIBUTING.md).

## License

This plugin is distributed under the same terms as Vim. See `:help license`

## Author information

This project is maintained by Stephen A. Davis.

GitHub: [webdavis](https://github.com/webdavis)
