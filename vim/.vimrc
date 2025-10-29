" --- Plugins ---
call plug#begin('~/.vim/plugged')
Plug 'sainnhe/everforest'
Plug 'tomasiser/vim-code-dark'
call plug#end()

" --- Theme ---
"let g:everforest_background = 'hard'
"let g:everforest_better_performance = 1
set background=dark
"silent! colorscheme everforest
silent! colorscheme codedark

" --- Basics ---
syntax on
set number
set splitbelow
set showmatch
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set showcmd
set showmode
set clipboard=unnamedplus

" --- Netrw ---
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_winsize = 25

" --- Split nav ---
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

