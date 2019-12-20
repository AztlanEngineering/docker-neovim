" ——————————————
" Plugins installation
" ——————————————

call plug#begin('~/.vim/plugged')

" General
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'jiangmiao/auto-pairs'
Plug 'Yggdroot/indentLine'
Plug 'junegunn/fzf.vim'
Plug 'skywind3000/asyncrun.vim'

"Theme
Plug 'morhetz/gruvbox'
Plug 'ryanoasis/vim-devicons'

"Syntax
Plug 'cakebaker/scss-syntax.vim' "scss
Plug 'hail2u/vim-css3-syntax' "css
Plug 'jparise/vim-graphql' "graphql
Plug 'pangloss/vim-javascript' "Javascript
Plug 'MaxMEllon/vim-jsx-pretty' "jsx
Plug 'tikhomirov/vim-glsl' "Gl Shader Lang
Plug 'plasticboy/vim-markdown' "Markdown, Md
Plug 'ekalinin/Dockerfile.vim' "Dockerfile
"Plug 'fatih/vim-go' "Go
"Plug 'derekwyatt/vim-scala' "scala
"Plug 'leafgarland/typescript-vim "

"Various Automation
Plug 'mattn/emmet-vim' "Html https://medium.com/vim-drops/be-a-html-ninja-with-emmet-for-vim-feee15447ef1

"Linting and autocomplete
Plug 'dense-analysis/ale' "Integrates with eslint/linter_name if eslint/linter_name binary in $PATH. Integrates with deoplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }


" Initialize plugin system
call plug#end()


" ——————————————
" General and filetypes
" ——————————————
syntax on
set shiftwidth=0    " Use tabstop
set softtabstop=-1  " Use shiftwidth
setlocal tabstop=2
set tabstop=2
set foldmethod=syntax
"Enable folding
set foldmethod=indent
set foldlevel=99

set nu "Line numbers
set numberwidth=3 "gutter

set backspace=indent,eol,start "Backspace normal behaviour

set cursorline "Cursor Position
set cursorcolumn

let mapleader=","

"Python
au Filetype *.py
\ setlocal tabstop=4 textwidth=79 expandtab autoindent fileformat=unix encoding=utf-8 
let python_highlight_all=1

"Js
au Filetype js,mjs,ts,jsx
\ setlocal tabstop=2
"autocmd BufWritePost *.js,*.jsx AsyncRun -post=checktime ./node_modules/.bin/eslint --fix %


"scss
au FileType less,css,scss,sass
\ setlocal tabstop=4 iskeyword+=-
"autocmd BufWritePost *.css,*.less,*.scss,*.sass AsyncRun -post=checktime ./node_modules/.bin/csscomb %

"Html
au FileType html
\ setlocal tabstop=2 

"json
autocmd Filetype json :IndentLinesDisable

"md"
autocmd Filetype md :IndentLinesDisable

" ——————————————
" Theme
" ——————————————

let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox "Will give an error on docker compilation, normal
autocmd BufRead,BufNewFile * syn match operators /[+\-\|\\\*\;\?\:\,\<\>\&\\!\\~\%\=]/ | hi operators guifg=#fe8019
autocmd BufRead,BufNewFile * syn match parens /[{}]/ | hi parens guifg=#689d6a
hi NERDTreeFile guifg=#

highlight! link NERDTreeFlags NERDTreeDir 
"https://github.com/ryanoasis/vim-devicons/issues/250

" ——————————————
" Keyboard Mappings
" ——————————————

nnoremap <C-J> <C-W><C-J> 
nnoremap <C-K> <C-W><C-K>
nnoremap l <C-W><C-L>
nnoremap h <C-W><C-H>

"Folding with space
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
"nnoremap <bs> Xi

map j :bprev<CR>
map k :bnext<CR>
"Folding with space
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>

nnoremap <leader>t :%s/<tab>/  /g<CR>
nnoremap <leader>n :NERDTreeToggle<CR>

"map <C-K> :bd<CR>
"map <C-L> :%bd|e#|NERDTree<CR>

" ——————————————
" Plugins Config
" ——————————————

"
" NERDTree
"

set hidden "To always open in same tab

autocmd VimEnter * NERDTree | wincmd w "Open on startup and focus
let NERDTreeShowHidden=1
set wildignore+=*.swo,*.pyc,*.o,*.svn,*.swp,*.class,*.hg,*.DS_Store,*.min.,*.min,.*swn,.*swm
let NERDTreeRespectWildIgnore=1
au BufReadPost *.html set syntax=html
"autocmd BufRead,BufNewFile * syn match parens2 /[()]/ | hi parens2 guibg=#a89984
"autocmd BufRead,BufNewFile * syn match parens3 /[\[\]]/ | hi parens3 guibg=#98971a

"
"  FZF
"

nmap ; :Buffers<CR>
nmap <Leader>f :Files<CR>
nmap = :Files<CR>
nmap <Leader>g :Tags<CR>

"
" AirlineConfig
"

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1


" DevIcons
set encoding=UTF-8


"
" Emmet
"

let g:user_emmet_leader_key=','

"
" indentLine
"

let g:indentLine_char_list = ['|', '¦', '┆', '┊']

"
" Linting
"
let g:ale_sign_error = '●' " Less aggressive than the default '>>'
let g:ale_sign_warning = '—'
let g:ale_lint_on_enter = 1 " Less distracting when opening a new file
let g:ale_fix_on_save = 1 " Set this variable to 1 to fix files when you save them
let b:ale_linters = {'javascript': ['eslint'], 'scss':['stylelint']}
let g:ale_fixers = {'javascript': ['eslint'], 'scss':['stylelint']}
let g:airline#extensions#ale#enabled = 1

"
" Deoplete.
"
let g:deoplete#enable_at_startup = 1

" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"


