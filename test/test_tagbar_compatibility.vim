" If Tagbar is not loaded then don't run these tests. This requires execution inside of
" the Ubuntu container created by Docker.
if !finddir('tagbar', expand('~/.vim') . '/**')
    finish
endif

" See this issue: https://github.com/majutsushi/tagbar/issues/146
let g:tagbar_show_linenumbers = 1
