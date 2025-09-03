" Which insane person said that " should be used for comments?

set tabstop=4
set autoindent
set smartindent
set relativenumber
" set noerrorbells " Disable beep on errors.
:filetype plugin on
:syntax on

" vim-plug cheatsheet
" :PlugInstall to install the plugins
" :PlugUpdate to install or update the plugins
" :PlugDiff to review the changes from the last update
" :PlugClean to remove plugins no longer in the list

" Plugin manager
call plug#begin()

" List your plugins here
Plug 'rluba/jai.vim'

call plug#end()
