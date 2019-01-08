setswitch.vim
=============

_setswitch.vim: a user extensible plugin that adds buffer local settings to all settings
in Vim._

I won't lie to you, setswitch is probably the most useful plugin I've created. I literally
wouldn't want to use Vim without it. Here's why:

- setswitch makes all settings buffer local. That means even settings like `hlsearch` are
  buffer local with setswitch.
- setswitch can enable settings for the active window, while disabling settings for the
  other windows.
- setswitch is only limited to your imagination. It works with _any setting_. Seriously,
  don't take my word for it. Just try it.

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

setswitch is user extensible, meaning that in the following settings `{option}` can be
replaced with any Vim/Neovim setting, and the **Lists** take any Vim/Neovim option.

#### g:setswitch_toggle

`g:setswitch_toggle` takes a **List** of options as an argument. It turns these options on
upon entering a window, and off upon exiting the window.

For example, putting the following in your `~/.vimrc` instructs setswitch to toggle them
when entering/exiting the window.

```vim
let g:setswitch_toggle = ['cursorline', 'cursorcolumn', 'colorcolumn', 'relativenumber']

" Or you can get creative.
let g:setswitch_toggle = ['cursorline', 'nocursorcolumn', 'nocolorcolumn', 'relativenumber']
```

#### g:setswitch_cmdmode_toggle

The command-line has it's own controller variable so that you can do unique things with
it. `g:setswitch_cmdmode_toggle` takes a **List** of options as an argument and turns
these options off upon entering the command-line, and on upon exiting the command-line.

The following setting turns `relativenumber` and `hlsearch` off when entering the
command-line.

```vim
let g:setswitch_cmdmode_toggle = ['relativenumber', 'hlsearch']
```

#### g:setswitch_hooks

g:setswitch_hooks takes a **List** of options instructing setswitch to listen for these
options being set using the `OptionSet` autocommand.  If they are set then setswitch will
store the option and value of the option in the dictionary `g:setswitch` by file name.

Put this in your `~/.vimrc` to instruct setswitch to store the values of the following
options whenever the user sets them. Whenever the cursor enters the window where these are
set, setswitch will set these values even if they were globally set in another window.
This pairs nicely with Tpope's [vim-unimpaired](https://github.com/tpope/vim-unimpaired)
plugin:

```vim
let g:setswitch_hooks = ['cursorline', 'cursorcolumn', 'relativenumber', 'wrap', 'hlsearch', 'colorcolumn']
```

#### g:setswitch_no{option}_filetypes

Put this in your `~/.vimrc`, replacing {option} with a Vim option, and set it equal to a
list of filetypes to prevent setswitch from setting the named option in those filetypes
when the window is focused. This is useful when you have added an option to
`g:setswitch_toggle` that you do not want in certain filetypes.

For example, put the following in your `~/.vimrc` to prevent these filetypes from setting
the options in the list.

```vim
let g:setswitch_nocursorline_filetypes = ['markdown', 'netrw', 'man', 'help']
let g:setswitch_nocursorcolumn_filetypes = ['markdown', 'netrw', 'man', 'help']
let g:setswitch_nocolorcolumn_filetypes = ['netrw', 'man', 'help']
```

#### g:setswitch_{option}

`g:setswitch_{option}` sets the default for whatever option you are setting, where
`{option}` is any option available in Vim/Neovim. This is helpful for values that are
evaluations of expressions. For example the value of `colorcolumn` is the summation of the
expression <textwidth + 1>:

```vim
let g:setswitch_colorcolumn = '&l:textwidth + 1'
```

Use this when you need the default to be set to something specific, like an **expression**
or a **string**.

## Contributing

See [CONTRIBUTING.md](/CONTRIBUTING.md).

## License

This plugin is distributed under the same terms as Vim. See `:help license`

## Author information

This project is maintained by Stephen A. Davis.

GitHub: [webdavis](https://github.com/webdavis)
