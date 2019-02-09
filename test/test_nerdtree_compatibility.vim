" If NERDTree is not loaded then don't run these tests. This requires execution inside of
" the Ubuntu container created by Docker.
if !finddir('nerdtree', expand('~/.vim') . '/**')
    finish
endif

" Tells NERDtree whether to display line numbers in the tree window.
let g:NERDTreeShowLineNumbers = 1
