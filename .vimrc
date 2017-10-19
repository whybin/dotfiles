" ------------
" Vim Plug
" ------------
call plug#begin('~/.vim/plugged') " Plugin directory

" Languages/completion
Plug 'othree/yajs.vim'            " JavaScript Syntax - Do not use with any other
Plug 'othree/html5.vim'
Plug 'digitaltoad/vim-pug'        " Pug template engine syntax
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'Shougo/neocomplete.vim'     " Autocompletion
Plug 'kitao/unity_dict'

" Formatting
Plug 'tpope/vim-commentary'
Plug 'junegunn/vim-easy-align'

" Display
Plug 'arcticicestudio/nord-vim'
Plug 'airblade/vim-gitgutter'

" Navigation
Plug 'christoomey/vim-tmux-navigator'
Plug 'airblade/vim-rooter'        " Change working directory to project root

" Misc
Plug '~/.vim/forks/vimwiki'

call plug#end()                   " Calls `filetype plugin indent on` and `syntax enable`
" ------------

" Rainbow Parentheses {{{
augroup rainbow_lisp
  autocmd!
  autocmd FileType lisp,clojure,scheme RainbowParentheses
augroup END
" }}}
" Neoclomplete {{{
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3

" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" }}}
" Unity dict {{{
au! BufNewFile,BufRead *.cs execute 'setlocal dictionary+=~/.vim/plugged/unity_dict/unity.dict'
" }}}
" Vim-easy-align {{{
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Don't ignore comments
let g:easy_align_ignore_groups = ['String']

let g:easy_align_delimiters = {
\  '/': { 
\       'pattern': '//\+\|/\*\|\*/',
\       'delimiter_align': 'l',
\       'ignore_groups': ['!Comment'],
\       'left_margin': 4
\   }
\ }
" }}}
" Color scheme {{{
colorscheme nord
set background=dark
set synmaxcol=200 " Syntax highlighting max chars
" }}}
" }}}

set encoding=utf8
set lazyredraw

" GUI
set guioptions-=r " Remove right scrollbar
set nu            " Line numbers

" Tabs / Indents
set autoindent
set smartindent
set expandtab " Expand to equivalent # of spaces
set shiftwidth=4
set tabstop=4

" Line breaks/wrapping
set lbr  " Automatic linebreaks
set textwidth=80
set colorcolumn=80
set wrap " Line wrap

set foldmethod=marker   " Use {{{ and }}} for code folding

" Autocompletion
set complete+=k

" -------------
" Custom remaps {{{
" -------------

let mapleader='-'
set showcmd " Show commands in lower right corner
" Shows Leader if `showcmd` enabled
map <Space> <Leader>

inoremap jk <Esc>
inoremap JK <Esc>

" Previously looks up the man page of the command
nnoremap K k

nnoremap <Leader>sv :source ~/.vimrc<Cr>
" Copy everything to system clipboard
nnoremap y* ggVG"+y

" -------------
" }}}
" -------------

" Change cursor shape between insert and normal mode
let &t_SI = "\<Esc>[5 q"
let &t_EI = "\<Esc>[1 q"

" ------------------------
" Racket Design Recipe {{{
" ------------------------
function! EnableRecipeAbbr()
    noreabbrev //SDR ;; Data Definition<cr>
        \;;<cr>
        \;; A natural number is either zero or the successor of a natural number<cr>
        \;;<cr>
        \;; Examples:<cr>
        \0<cr>
        \(succ 0) ;; 1<cr>
        \(succ (succ 0)) ;; 2<cr>
        \<cr>
        \;; <cr>
        \;;<cr>
        \;; input: <cr>
        \;; output: <cr><cr><cr>
        \;; Test cases

    noreabbrev //DR ;; Data Definition<cr>
        \;;<cr>
        \;; A_ _ list is either the empty list or (cons item list),<cr>
        \;; where item is a_ _ and list is a_ _ list<cr>
        \;;<cr>
        \;; Examples:<cr>
        \(define list0 empty)<cr>
        \(define list1 (list ))<cr>
        \(define list2 (list ))<cr>
        \<cr>
        \;; <cr>
        \;;<cr>
        \;; input: <cr>
        \;; output: <cr><cr><cr>
        \;; Test cases
endfunction

function! EnableAnalysisAbbr()
    noreabbrev letp Let P(n) be the greatest number of elementary operations<cr>
                \used to evaluate the procedure _ applied to a list of any<cr>
                \length n.<cr>
                \<cr>
                \P(0) = A<cr>
                \P(n) <=
endfunction

au! BufNewFile,BufRead *.rkt call EnableRecipeAbbr()
au! BufNewFile,BufRead *.txt call EnableAnalysisAbbr()

" ------------------------
" }}}
" ------------------------
