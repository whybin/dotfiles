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

" Status
set statusline=%f\ %#diffadd#\ BUF\ %02n\ »\ COL\ %02c\ %#matchparen#
" TODO: Move to autocommand
set statusline+=\ %{system('git\ rev-parse\ --abbrev-ref\ HEAD\ 2>\ /dev/null\ \|\ xargs\ printf\ \"*%s\"')}
set laststatus=2  " Always show statusline

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
nnoremap y* ggVG"+y''

" -------------
" }}}
" -------------

" Change cursor shape between insert and normal mode
let &t_SI = "\<Esc>[5 q"
let &t_EI = "\<Esc>[1 q"

" ------------------------
" Analysis {{{
" ------------------------
function! EnableAnalysisAbbr()
    noreabbrev letp Let P(n) be the greatest number of elementary operations<cr>
                \used to evaluate the procedure _ applied to a list of any<cr>
                \length n.<cr>
                \<cr>
                \P(0) = A<cr>
                \P(n) <=
endfunction

au! BufNewFile,BufRead *.txt call EnableAnalysisAbbr()

" ------------------------
" }}}
" ------------------------

" --------
" OCaml {{{
" --------
function! EnableOcamlRecipe()
    noreabbrev _DR #use "CS17setup.ml";;<cr><cr>
                \(* Inputs: _ *)<cr>
                \(* Outputs: _ *)<cr><cr><cr>
                \"Test cases for _:";;
endfunction

function! PrepareOcaml()
    setlocal shiftwidth=2
    setlocal tabstop=2
endfunction

augroup ocaml
    au!
    au BufNewFile,BufRead *.ml call EnableOcamlRecipe()
    au BufNewFile,BufRead *.ml call PrepareOcaml()
augroup END
" --------
" }}}
" --------

" --------------
" IndentWord {{{
" --------------
function! IndentWord(toBack)
    if line('.') == 1
        echo 'Cannot align top line'
        return
    endif

    let indentIndex = matchstrpos(getline('.'), '\S')[1]
    if indentIndex == -1
        echo 'Cannot indent empty line'
        return
    endif

    " Setup string and regex
    let lineAbove = getline(line('.') - 1)
    let wordRgx = '\v(\w+|[^-a-zA-Z0-9 ]+)'
    if a:toBack
        " Ensures gets last occurrence
        let lineAbove = strpart(lineAbove, 0, indentIndex)
        let wordRgx .= ' *$'

        " Setup starting index and count
        let nextIndex = [v:null, indentIndex]
        let i = 0
    else
        let nextIndex = matchstrpos(lineAbove, wordRgx, indentIndex)
        " Doesn't count if current line is already aligned to a word
        let i = nextIndex[1] > indentIndex ? 1 : 0
    endif

    " Get new indentation level
    while i < v:count1
        if a:toBack
            let nextIndex = matchstrpos(
                        \strpart(lineAbove, 0, nextIndex[1]), wordRgx)
        else
            let prev = nextIndex[1]
            let nextIndex = matchstrpos(lineAbove, wordRgx, nextIndex[2])

            if nextIndex[1] == -1
                let nextIndex[1] = prev
                break
            endif
        endif

        let i += 1
    endwhile

    " Modify current line
    let line = substitute(getline('.'), '\v^\s*', repeat(' ', nextIndex[1]), '')
    call setline('.', line)
    normal! ^
endfunction

nnoremap <silent> <Tab>w :<C-u>call IndentWord(0)<cr>
nnoremap <silent> <Tab>b :<C-u>call IndentWord(1)<cr>
" --------------
" }}}
" --------------
