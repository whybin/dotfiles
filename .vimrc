" ------------
" Vim Plug
" ------------
call plug#begin('~/.vim/plugged') " Plugin directory

" Languages/completion
Plug 'othree/yajs.vim'           " JavaScript Syntax - Do not use with any other
Plug 'othree/html5.vim'
Plug 'digitaltoad/vim-pug'       " Pug template engine syntax
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'kitao/unity_dict'
Plug 'lifepillar/vim-mucomplete' " Autocompletion

" Formatting
Plug 'tpope/vim-commentary'
Plug 'junegunn/vim-easy-align'

" Display
Plug 'whybin/Transient-256'
Plug 'airblade/vim-gitgutter'

" Navigation
Plug 'christoomey/vim-tmux-navigator'
if !empty(glob('/usr/local/opt/fzf'))
    Plug '/usr/local/opt/fzf'
    Plug 'junegunn/fzf.vim'
endif

call plug#end()                   " Calls `filetype plugin indent on` and `syntax enable`
" ------------

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
vnoremap K k

nnoremap <Leader>sv :source ~/.vimrc<Cr>
nnoremap <Leader>g :!git<Space>
" Copy everything to system clipboard
nnoremap y* ggVG"+y''

" Save read-only files: https://stackoverflow.com/a/7078429
cnoremap w!! w !sudo tee > /dev/null %

" -------------
" }}}
" -------------

" Rainbow Parentheses {{{
augroup rainbow_lisp
  autocmd!
  autocmd FileType lisp,clojure,scheme,ocaml RainbowParentheses
augroup END
" }}}
" Mucomplete {{{
set completeopt+=menuone,noinsert
set shortmess+=c " Hide completion messages

let g:mucomplete#enable_auto_at_startup = 1
inoremap <expr> <cr> mucomplete#popup_exit("\<cr>")
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
colorscheme transient
set background=dark
set synmaxcol=200 " Syntax highlighting max chars
" }}}
" GitGutter {{{
hi! link GitGutterAdd DiffAdd
hi! link GitGutterChange DiffChange
hi! link GitGutterDelete DiffDelete
" }}}
" fzf.vim {{{
nnoremap <Leader>ff :Files<cr>
" }}}

set encoding=utf8
set lazyredraw

" Display
set nu                   " Line numbers
set cursorline           " Highlight line of cursor
set incsearch            " Incremental search
set completeopt-=preview " Disable scratch preview window
" No visual bell
set vb t_vb=

" Wildmenu
set wildmenu           " Command line completion highlighting
set wildmode=list:full " <Tab> on command line lists & cycles through matches

" Tabs / Indents
set autoindent
set smartindent
set expandtab " Expand to equivalent # of spaces
set shiftwidth=4
set tabstop=4

" Line breaks/wrapping
set lbr            " Automatic linebreaks
set textwidth=80
set colorcolumn=+1 " Set to 1 column after `textwidth`
set wrap           " Line wrap

set backspace=indent,start " Allow backspacing over autoindent & start of insert
set foldmethod=marker      " Use {{{ and }}} for code folding

" Autocompletion
set complete+=k

" Change cursor shape between insert and normal mode
let &t_SI = "\<Esc>[5 q"
let &t_EI = "\<Esc>[1 q"

" ----------
" StatusLine {{{
" ----------
function! SetStatusLine()
    let status=' %f %#MatchParen# BUF %02n » COL %02c %#Underlined# '
                \. system('git symbolic-ref --short HEAD 2> /dev/null '
                         \. '| xargs printf "*%s"')
    return status
endfunction
set statusline=%!SetStatusLine()
set laststatus=2  " Always show statusline
" ----------
" }}}
" ----------

" --------
" OCaml {{{
" --------
function! EnableOcamlRecipe()
    noreabbrev _DR #use "CS17setup.ml" ;;<cr><cr>
                \(* Data Definitions<cr>
                \_ *)<cr><cr>
                \(* Examples *)<cr><cr>
                \(* Inputs: _<cr>
                \Outputs: _ *)<cr><cr><cr>
                \"Test cases for _:" ;;
endfunction

function! PrepareOcaml()
    setlocal shiftwidth=2
    setlocal tabstop=2
    " Quick hack to override rainbow parentheses
    syntax region ocamlComment start=/(\*/ end=/\*)/
    hi link ocamlComment Comment
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
