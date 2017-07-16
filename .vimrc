" No problem in not behaving like standard vi
set nocompatible
" Ensuring backspace behaviour to be predictable
set backspace=indent,eol,start
" Enabling automatic indentation
filetype plugin indent on
" Settings for golang dev
autocmd Filetype go set textwidth=0
autocmd Filetype go set noexpandtab
autocmd Filetype go set tabstop=4
autocmd Filetype go set shiftwidth=4
autocmd Filetype go set softtabstop=4
autocmd Filetype go set number
autocmd Filetype go command! Fmt %!gofmt
autocmd FileType go set formatprg=gofmt
" Settings for python dev
autocmd Filetype py set textwidth=0
autocmd Filetype py set noexpandtab
autocmd Filetype py set tabstop=4
autocmd Filetype py set shiftwidth=4
autocmd Filetype py set softtabstop=4
autocmd Filetype py set number
"General editing settings
set tabstop=2
set shiftwidth=2
set softtabstop=2
set ts=2
set expandtab
set colorcolumn=81
syntax on
" Fix for directional keys if using mosh
"set t_ku=[A
"set t_kl=[D
"set t_kd=[B
"set t_kr=[C
" Better theme for remote console
color desert
