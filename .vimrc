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
" Settings for python dev following PEP8
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |
    \ set encoding=utf-8

au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/
"General editing settings
set tabstop=2
set shiftwidth=2
set softtabstop=2
set ts=2
set expandtab
set colorcolumn=81
set textwidth=80
set formatoptions+=t
set cursorline
set laststatus=2
syntax on
" Fix for directional keys if using mosh
"set t_ku=[A
"set t_kl=[D
"set t_kd=[B
"set t_kr=[C
" Better theme for remote console
color dracula
" airline configuration
let g:airline_powerline_fonts = 1 
