" Share config between vim and neovim
" mkdir -p ~/.local/share/nvim/
" ln -s ~/.vim ~/.local/share/nvim/site
" mkdir -p ~/.config/nvim/
" ln -s ~/.vimrc .config/nvim/init.vim

" Compatibility with vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" No problem in not behaving like standard vi
set nocompatible
" Ensuring backspace behaviour to be predictable
set backspace=indent,eol,start
" Fix for directional keys if using mosh
" TODO: run only if inside a mosh session
" set t_ku=[A
" set t_kl=[D
" set t_kd=[B
" set t_kr=[C

" Utility variables
let oldversion = 0
if has('nvim')
  let oldversion = !has('nvim-0.4.3')
else
  let oldversion = !has('patch-8.1.1719')
endif

"Allow correct mouse behaviour inside tmux
if !has('nvim')
  set ttymouse=xterm2
endif
set mouse=a

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

" Install vim-plug before calling it
source $HOME/.vim/config/plug.vim

" Plugin catalog
call plug#begin('~/.vim/plugged')

Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'roxma/vim-tmux-clipboard'
Plug 'tmux-plugins/vim-tmux'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-python/python-syntax'
"Plug 'fatih/vim-go'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'rust-lang/rust.vim'
Plug 'sheerun/vim-polyglot'
Plug 'dracula/vim', {'as': 'dracula'}
Plug 'saltstack/salt-vim'
Plug 'bfrg/vim-cpp-modern'
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
Plug 'vim-ruby/vim-ruby'
Plug 'vim-syntastic/syntastic'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'justinmk/vim-sneak'
"Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'mhinz/vim-startify'
Plug 'Shirk/vim-gas'
Plug 'wincent/vim-clipper'
if oldversion == 0
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif

Plug 'rhysd/vim-clang-format', {'for' : ['c', 'cpp']}

call plug#end()

" Plugin configuration
let g:dracula_colorterm = 0
colorscheme dracula
let g:airline_theme='dracula'
let g:airline_powerline_fonts = 1
let g:python_highlight_all = 1
let g:vim_markdown_folding_disabled = 1
let g:AWSVimValidate = 1
let g:rustfmt_autosave = 1
" Syntastic Config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_sh_shellcheck_args="--external-sources"
let g:loaded_syntastic_java_javac_checker = 1
" NERDTree configuration
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
" Rainbow parenthesis config
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]
autocmd FileType * RainbowParentheses
" Startify config
let g:startify_session_dir = '~/.vim/session'
" Clipper config
let g:ClipperAddress='~/.clipper.sock'
let g:ClipperPort=0
" clang format config
let g:clang_format#auto_format=1

" Also run pip install jedi
" and :CocInstall coc-cfn-lint coc-clangd coc-css coc-cssmodules
" coc-html coc-json coc-python coc-rls coc-rust-analyzer coc-sh coc-sql
" coc-tsserver coc-vimlsp coc-xml coc-yaml
" More extensions at https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions
if oldversion == 0
source $HOME/.vim/config/coc.vim
endif

set number

" Key Mappings
nnoremap <silent> <C-T> :TagbarToggle<CR>
nnoremap <silent> <C-b> :NERDTreeToggle<CR>
" File Finder
nnoremap <C-p> :FZF<CR>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \}

if has('nvim')
  " open new split panes to right and below
  set splitright
  set splitbelow
  " turn terminal to normal mode with escape
  tnoremap <Esc> <C-\><C-n>
  " start terminal in insert mode
  au BufEnter * if &buftype == 'terminal' | :startinsert | endif
  " open terminal on ctrl+n
  function! OpenTerminal()
    split term://zsh
      resize 20
      endfunction
      nnoremap <c-n> :call OpenTerminal()<CR>

  " use alt+hjkl to move between split/vsplit panels
  tnoremap <A-h> <C-\><C-n><C-w>h
  tnoremap <A-j> <C-\><C-n><C-w>j
  tnoremap <A-k> <C-\><C-n><C-w>k
  tnoremap <A-l> <C-\><C-n><C-w>l
  nnoremap <A-h> <C-w>h
  nnoremap <A-j> <C-w>j
  nnoremap <A-k> <C-w>k
  nnoremap <A-l> <C-w>l
end

" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" TODO: move this all to filetype plugins?
" https://superuser.com/questions/632657/how-to-setup-vim-to-edit-both-makefile-and-normal-code-files

" Syntax highlight fixes for assembly
augroup nasm
  au!
  autocmd BufNewFile,BufRead *.nasm set syntax=nasm
augroup END
augroup gas
  au!
  autocmd BufNewFile,BufRead *.S,*.as set syntax=gas
augroup END

