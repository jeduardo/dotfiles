" No problem in not behaving like standard vi
set nocompatible
" Ensuring backspace behaviour to be predictable
set backspace=indent,eol,start
" Fix for directional keys if using mosh
" set t_ku=[A
" set t_kl=[D
" set t_kd=[B
" set t_kr=[C

" General editing settings
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

" Plugin catalog
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-python/python-syntax'
Plug 'fatih/vim-go'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'rust-lang/rust.vim'
Plug 'dracula/vim', {'as': 'dracula'}
Plug 'saltstack/salt-vim'
Plug 'bfrg/vim-cpp-modern'

call plug#end()

" Plugin configuration
let g:go_version_warning = 0 "Allow the config to run on Debian stretch
let g:dracula_colorterm = 0
colorscheme dracula
let g:airline_theme='dracula'
let g:airline_powerline_fonts = 1
let g:python_highlight_all = 1
let g:vim_markdown_folding_disabled = 1
