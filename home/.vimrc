set t_Co=256
set nocompatible
set backspace=indent,eol,start
set nobackup
set noundofile
set history=500
set ruler
set showcmd
set mouse=a
set laststatus=2
set hidden
set nowrap
set number
set cursorline
set foldmethod=indent
set nofoldenable
set hlsearch
set incsearch
set ignorecase
set smartcase
set autoindent
set autowrite
set gcr=a:block-blinkon0
set lcs=tab:>-,trail:-
let mapleader = ";"

set ts=4 sts=4 sw=4 expandtab
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=usc-bom,utf-8,chinese,gb18030
set termencoding=utf-8
set ff=unix

set tags=~/.tags,.tags

let g:airline_theme='bubblegum'
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:NERDSpaceDelims = 1
let g:gutentags_cache_dir = expand('~/.cache/tags')
let g:fzf_layout = { 'down': '~40%' }
let g:fzf_action = {'ctrl-t': 'tab split', 'ctrl-x': 'split', 'ctrl-v': 'vsplit'}

filetype off

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'airblade/vim-gitgutter'
Plug 'vim-scripts/a.vim'
Plug 'tsaleh/vim-tmux'
Plug 'junegunn/vim-easy-align', { 'on': '<Plug>(EasyAlign)' }
Plug 'easymotion/vim-easymotion'
Plug 'scrooloose/nerdcommenter', { 'on': 'NERDCommenterToggle' }
Plug 'google/yapf', { 'rtp': 'plugins/vim', 'for': 'python' }
Plug 'rhysd/vim-clang-format', { 'for': ['c', 'cpp', 'objc'] }

call plug#end()

filetype plugin indent on
syntax enable

colorscheme Tomorrow-Night
set t_ut=

nmap <F4> @q
nmap <C-N> :tn<CR>
nmap <leader>ch :A<CR>
map <C-]> g<C-]> 
vmap <Enter> <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
nmap s <Plug>(easymotion-s2)
nmap mm :GitGutterNextHunk<CR>
nmap mn :GitGutterPrevHunk<CR>
nmap mr :GitGutterRevertHunk<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>f :Rg<CR>

augroup vimrcEx
    au!
    autocmd FileType text setlocal textwidth=78
    autocmd FileType python set omnifunc=pythoncomplete#Complete
    autocmd FileType python set ts=4 sts=4 sw=4 expandtab textwidth=0 nowrap
    autocmd FileType c,cpp,h set ts=4 sw=4 sts=4 expandtab cinoptions+=g0-N-s
    autocmd FileType c,cpp,objc map <C-J> :<C-u>ClangFormat<CR>
    autocmd FileType c,cpp,objc imap <C-J> :ClangFormat<CR>
    autocmd FileType python map <C-J> :call yapf#YAPF()<cr>
    autocmd FileType python imap <C-J> :call yapf#YAPF()<cr>

    autocmd BufReadPost * call s:RestoreCursor()
augroup END

function! s:RestoreCursor()
  if line("'\"") > 1 && line("'\"") <= line("$") 
    normal! g`"
  endif
endfunction

function! s:FormatJson()
  execute '%!python -c "import sys, json; data = json.load(sys.stdin); json.dump(data, sys.stdout, indent=4, ensure_ascii=False)"'
  execute '%s/ \+$//ge'
  set filetype=json
  1
endfunction

function! s:Rg(bang, args)
  let command = 'rg --column --line-number --no-heading --color=always --smart-case ' . shellescape(a:args)
  call fzf#vim#grep(command, 1, fzf#vim#with_preview(), a:bang)
endfunction

command! JsonFormat call s:FormatJson()

if executable('rg')
  command! -bang -nargs=* Rg call s:Rg(<bang>0, <q-args>)
endif
