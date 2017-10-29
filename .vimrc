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
" Vim Commentary {{{
au! FileType ocaml setlocal commentstring=(*\ %s\ *)
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

" --------
" OCaml {{{
" --------
function! EnableOcamlRecipe()
    noreabbrev _DR #use "CS17setup.ml" ;;<cr><cr>
                \(* Data Definitions<cr>
                \_ *)<cr><cr>
                \(* Examples *)<cr><cr>
                \(* Inputs: _ *)<cr>
                \(* Outputs: _ *)<cr><cr><cr>
                \"Test cases for _:" ;;
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
function! s:GetTextCols(text, rgx, offset)
    let cols = []
    let nextIndex = [v:null, v:null, 0]

    while v:true
        let nextIndex = matchstrpos(a:text, a:rgx, nextIndex[2])
        if nextIndex[1] == -1
            break
        endif
        call add(cols, nextIndex[1] + a:offset)
    endwhile

    return cols
endfunction

function! IndentWord(toBack)
    let startLnum = line('.')
    if startLnum == 1
        echo 'Cannot align top line'
        return
    endif

    if len(getline('.')) == 0
        echo 'Cannot indent empty line'
        return
    endif

    " Setup vars
    let lnum = startLnum - 1
    let cols = []
    let bounds = [0, 0]
    let wordRgx = '\v(\w+|[^a-zA-Z0-9 ]+)'

    " Populate columns
    while lnum > 0
        let text = getline(lnum)
        if len(text) == 0
            let lnum -= 1
            continue
        endif

        " Left partition
        let lText = strpart(text, 0, bounds[0])
        let lCols = s:GetTextCols(lText, wordRgx, 0)
        if len(lCols) > 0
            let cols = lCols + cols
        endif

        " Right partition
        let rText = strpart(text, bounds[1])
        let rCols = s:GetTextCols(rText, wordRgx, bounds[1])
        if len(rCols) > 0
            let cols += rCols[0] > 0 && rCols[0] == bounds[1]
                        \? rCols[1:] : rCols
        endif

        if cols[0] == 0
            break
        endif

        let bounds = [cols[0], max([bounds[1], len(text) - 1])]
        let lnum -= 1
    endwhile

    " Determine new indent column
    let i = -1
    let targetFound = v:false
    let startIndex = matchstrpos(getline('.'), '\S')[1]

    while i < len(cols) - 1
        let i += 1

        if a:toBack
            if startIndex > cols[i]
                continue
            endif
            let targetCol = cols[max([0, i - v:count1])]
        else
            if startIndex >= cols[i]
                continue
            endif
            let targetCol = cols[min([len(cols), i + v:count1]) - 1]
        endif

        let targetFound = v:true
        break
    endwhile

    if !targetFound
        return
    endif

    " Modify current line
    let line = substitute(getline('.'), '\v^\s*', repeat(' ', targetCol), '')
    call setline('.', line)
    normal! ^
endfunction

nnoremap <silent> \w :<C-U>call IndentWord(v:false)<CR>
nnoremap <silent> \b :<C-U>call IndentWord(v:true)<CR>

" --------------
" }}}
" --------------
