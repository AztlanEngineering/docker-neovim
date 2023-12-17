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
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
"Plug 'skywind3000/asyncrun.vim'
"Plug 'frazrepo/vim-rainbow' "Matches colors for opening and closing parens
Plug 'andymass/vim-matchup' "Extend usage of % key

"Theme
"Plug 'morhetz/gruvbox'
Plug 'ryanoasis/vim-devicons'
Plug 'cocopon/iceberg.vim'
"Plug 'AlexvZyl/nordic.nvim', { 'branch':'main' }
Plug 'vim-airline/vim-airline-themes'

"Syntax
Plug 'cakebaker/scss-syntax.vim' "scss
Plug 'hail2u/vim-css3-syntax' "css
Plug 'jparise/vim-graphql' "graphql
Plug 'pangloss/vim-javascript' "Javascript
Plug 'jxnblk/vim-mdx-js' "Mdx, for storybook docs, experimental module
Plug 'MaxMEllon/vim-jsx-pretty' "jsx
Plug 'tikhomirov/vim-glsl' "Gl Shader Lang
Plug 'plasticboy/vim-markdown' "Markdown, Md
Plug 'ekalinin/Dockerfile.vim' "Dockerfile
"Plug 'fatih/vim-go' "Go
"Plug 'derekwyatt/vim-scala' "scala

Plug 'peitalin/vim-jsx-typescript' "tsx
Plug 'leafgarland/typescript-vim' "ts syntax
"Plug 'Shougo/vimproc.vim', {'do' : 'make'}
"Plug 'Quramy/tsuquyomi' "tsserver client featuresg
Plug 'nvie/vim-flake8' "Python 
Plug 'cespare/vim-toml' "Vim TOML
Plug 'rust-lang/rust.vim'

"Various
Plug 'mattn/emmet-vim' "Html https://medium.com/vim-drops/be-a-html-ninja-with-emmet-for-vim-feee15447ef1
Plug 'jmcantrell/vim-virtualenv' "Detect python venv
Plug 'github/copilot.vim' "Then run :Copilot setup

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
set expandtab "Tabs to spaces
setlocal tabstop=2
set tabstop=2
set foldmethod=syntax
"Enable folding
set foldmethod=indent
set foldlevel=99
set conceallevel=0

set nu rnu "Line numbers, hybrid mode
set numberwidth=3 "gutter

set backspace=indent,eol,start "Backspace normal behaviour

set cursorline "Cursor Position
set cursorcolumn

let mapleader=","

" Mouse mode, cf https://unix.stackexchange.com/questions/50733/cant-use-mouse-properly-when-running-vim-in-tmux
if !has('nvim')
  set ttymouse=xterm2
endif
set mouse=a

"THIS IS A TEST !!
" Disable Background Color Erase (BCE) so that color schemes
" render properly when inside 256-color tmux and GNU screen.
"if &term =~ '256color'
"    set t_ut=
"endif
"https://vi.stackexchange.com/questions/13458/make-vim-show-all-the-colors
set termguicolors
if !has('nvim') && $TERM ==# 'screen-256color'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif


"Python
au Filetype *.py
\ setlocal tabstop=4 textwidth=79 expandtab autoindent fileformat=unix encoding=utf-8 
let python_highlight_all=1
let g:python3_host_prog="/usr/bin/python3"

"js
au Filetype js,cjs,jsx,mjs,ts,jsx
\ setlocal tabstop=2 softtabstop=2 shiftwidth=2
"autocmd BufWritePost *.js,*.jsx AsyncRun -post=checktime ./node_modules/.bin/eslint --fix %

"scss
au FileType less,css,scss,sass
\ setlocal tabstop=2 softtabstop=2 shiftwidth=2 iskeyword+=-
"autocmd BufWritePost *.css,*.less,*.scss,*.sass AsyncRun -post=checktime ./node_modules/.bin/csscomb %

"Html
au FileType html
\ setlocal tabstop=2 softtabstop=2 shiftwidth=2

" JSON
autocmd FileType json setlocal conceallevel=0 tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType json IndentLinesDisable
let g:vim_json_conceal=0

" Markdown
autocmd FileType markdown setlocal conceallevel=0
autocmd FileType markdown IndentLinesDisable
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:indentLine_fileTypeExclude = ['markdown']

"yaml
autocmd FileType yaml,yml 
\ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" ——————————————
" Theme
" ——————————————

"let g:gruvbox_contrast_dark = 'hard'
"colorscheme gruvbox "Will give an error on docker compilation, normal
colorscheme iceberg "Will give an error on docker compilation, normal
let g:airline_left_sep = ''
let g:airline_right_sep = ''
set fillchars+=vert:\ 
hi VertSplit cterm=NONE ctermbg=NONE ctermfg=NONE gui=NONE guibg=NONE guifg=NONE
hi Normal guibg=NONE ctermbg=NONE
hi clear EndOfBuffer
hi clear NonText
hi clear LineNr ctermbg=NONE guibg=NONE
hi clear airline_tabfill
hi clear airline_a
hi clear airline_a_inactive
hi! airline_c ctermbg=NONE guibg=NONE
autocmd BufRead,BufNewFile * syn match operators /[+\-\|\\\*\;\?\:\,\<\>\&\\!\\~\%\=]/ | hi operators guifg=#fe8019
autocmd BufRead,BufNewFile * syn match parens /[{}]/ | hi parens guifg=#689d6a
hi NERDTreeFile guifg=#

highlight! link NERDTreeFlags NERDTreeDir 
"https://github.com/ryanoasis/vim-devicons/issues/250

" ——————————————
" Keyboard Mappings
" ——————————————

nnoremap j <C-W><C-J> 
nnoremap k <C-W><C-K>
nnoremap l <C-W><C-L>
nnoremap h <C-W><C-H>

nnoremap K :ALEHover<CR>
nnoremap <silent> gr :ALEFindReferences<CR>

nnoremap <leader>r <C-W>r
nnoremap <leader>R <C-W>R

"split
nnoremap <leader>v <C-W>v
nnoremap <leader>s <C-W>s

"reload
nnoremap <leader>e :e!<CR>

"toggle line number
nnoremap <leader>l :set number!<CR>
nnoremap <leader>L :set relativenumber!<CR>

"toogle ALE
nnoremap <leader>a :ALEToggleBuffer<CR>
nnoremap <leader>z :ALEPrevious<CR>
nnoremap <leader>x :ALENext<CR>
nnoremap <leader>d :ALEGoToDefinition<CR>

nnoremap <leader>y :IndentLinesToggle<CR>

"Fix the file in case it doesnt work on save
nnoremap <leader>f :ALEFix<CR>
nnoremap <leader>c :!eslint --fix %<CR>

noremap <leader><Space> :w<CR>
noremap <leader>q :q!<CR>
noremap <leader>b :bd!<CR>

"Folding with space
nnoremap <bs>

"Mapping the delete key (bug on arch + ssh)
map <F1> <Del>
imap <F1> <Del>

"Mapping buffers
"map j :bprev<CR>
"map k :bnext<CR>
"Folding with space
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>

noremap <leader>t :retab<CR>
"nnoremap <leader>t :%s/<tab>/  /g<CR>
nnoremap <leader>n :NERDTreeToggle<CR>

"map <C-K> :bd<CR>
"map <C-L> :%bd|e#|NERDTree<CR>

"Fix the scroll bug, force redraw
noremap } }<C-L>
noremap { {<C-L>

" https://til.hashrocket.com/posts/wa1bvrgjdd-escaping-terminal-mode-in-an-nvim-terminal#:~:text=Try%20hitting%20though%20and,transitioned%20back%20to%20Normal%20mode.
if has("nvim")
  au TermOpen * tnoremap <Esc> <c-\><c-n>
  au FileType fzf tunmap <Esc>
endif


"https://vim.fandom.com/wiki/Search_for_visually_selected_text
"vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" ——————————————
" Plugins Config
" ——————————————

"
" NERDTree
"

set hidden "To always open in same tab

let g:NERDTreeWinSize=22

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

"let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_char_list = ['|'] "For easier processing of terminal copy and paste
" Linting
"
let g:ale_sign_error = '●' " Less aggressive than the default '>>'
let g:ale_sign_warning = '—'
let g:ale_lint_on_enter = 1 " Less distracting when opening a new file
let g:ale_fix_on_save = 1 " Set this variable to 1 to fix files when you save them
let g:ale_linters = {
\  'javascript': ['eslint'], 
\  'javascriptreact': ['eslint'], 
\  'scss':['stylelint'],
\  'typescript':['eslint', 'tsserver'],
\  'typescriptreact':['eslint', 'tsserver']
\}
let g:ale_fixers = {
\  'javascript': ['eslint'], 
\  'javascriptreact': ['eslint'], 
\  'scss':['stylelint'], 
\  'html':['prettier'],
\  'typescript': ['prettier', 'eslint'],
\  'typescriptreact': ['prettier', 'eslint']
\}

let g:ale_linter_aliases = {'jsx': 'javascript'}

let g:airline#extensions#ale#enabled = 1
let g:ale_typescript_prettier_use_local_config = 1

"
" Deoplete.
"
let g:deoplete#enable_at_startup = 1

" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" set filetypes as typescriptreact
autocmd BufNewFile,BufRead *.tsx set filetype=typescriptreact
autocmd BufNewFile,BufRead *.jsx set filetype=javascriptreact
autocmd BufNewFile,BufRead *.ts set filetype=typescript


