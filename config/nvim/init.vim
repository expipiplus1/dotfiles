set nocompatible
filetype off

if has('NVIM')
    let s:editor_root=expand("~/.config/nvim")
else
    let s:editor_root=expand("~/.vim")
endif

let &rtp = &rtp . ',' . s:editor_root
if has('nvim')
  let &rtp = &rtp . ',' . expand("~/opt/bin/nvim")
endif

let s:use_ghc_mod = 1

call plug#begin(s:editor_root . '/plugged')

if has('nvim')
  Plug 'Shougo/deoplete.nvim'
else
  Plug 'Shougo/neocomplete.vim'
endif
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimproc.vim'
Plug 'Shougo/neco-vim'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

" Plug 'altercation/vim-colors-solarized'
Plug 'chriskempson/base16-vim'

Plug 'beyondmarc/hlsl.vim'
Plug 'itchyny/lightline.vim'
Plug 'kien/ctrlp.vim'

Plug 'stephpy/vim-yaml'

Plug 'Twinside/vim-hoogle'
if(s:use_ghc_mod)
  Plug 'expipiplus1/ghcmod-vim'
else
  Plug 'louispan/vim-hdevtools'
endif
Plug 'eagletmt/neco-ghc'
Plug 'eagletmt/unite-haddock'
Plug 'neovimhaskell/haskell-vim'
Plug 'mpickering/hlint-refactor-vim'

Plug 'gabrielelana/vim-markdown'

Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-function'
Plug 'glts/vim-textobj-comment'
Plug 'gibiansky/vim-textobj-haskell'

Plug 'benekastah/neomake'

Plug 'tpope/vim-abolish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

Plug 'vim-scripts/Align'
Plug 'xolox/vim-easytags'
Plug 'xolox/vim-misc'
Plug 'christoomey/vim-tmux-navigator'
Plug 'milkypostman/vim-togglelist'

Plug 'LnL7/vim-nix'

Plug 'blueyed/vim-diminactive'
Plug 'tmux-plugins/vim-tmux-focus-events'

Plug 'Rip-Rip/clang_complete'

call plug#end()
" End of plug stuff

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Run sensible first, so we can override things if we need to
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
runtime! plugin/sensible.vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" neovim fixes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" workaround for neovim 2048
if has('nvim')
  nmap <bs> :<c-u>TmuxNavigateLeft<cr>
endif

" from https://github.com/neovim/neovim/issues/2017#issuecomment-75235455
set timeout

"NeoVim handles ESC keys as alt+key, set this to solve the problem
if has('nvim')
 set ttimeout
 set ttimeoutlen=0
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set exrc
set secure

syntax on
filetype on
filetype plugin on
filetype indent on

set ignorecase
set smartcase

set title

set history=1000

set tags=./.tags;

" Save your backups to a less annoying place than the current directory.
" If you have .vim-backup in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/backup or . if all else fails.
if isdirectory(s:editor_root . '/backup') == 0
  :!mkdir -p expand(s:editor_root . '/backup') >/dev/null 2>&1
endif
set backupdir-=.
set backupdir+=.
set backupdir-=~/
execute "set backupdir^=" . s:editor_root . '/backup//'
set backupdir^=./.vim-backup//
set backup

" Save your swp files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/swap, ~/tmp or .
if isdirectory(s:editor_root . '/swap') == 0
  :!mkdir -p expand(s:editor_root . '/swap') >/dev/null 2>&1
endif
set directory=./.vim-swap//
execute "set directory+=" . s:editor_root . '/swap//'
set directory+=~/tmp//
set directory+=.

if exists("+undofile")
  " undofile - This allows you to use undos after exiting and restarting
  " This, like swap and backups, uses .vim-undo first, then ~/.vim/undo
  " :help undo-persistence
  " This is only present in 7.3+
  if isdirectory(s:editor_root . '/undo') == 0
    :!mkdir -p expand(s:editor_root . '/undo') > /dev/null 2>&1
  endif
  set undodir=./.vim-undo//
  execute "set undodir+=" . s:editor_root . '/undo//'
  set undofile
endif

set hidden

set tabpagemax=1000

set ffs=unix,dos

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Interface
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

set switchbuf+=usetab

set ruler

set scrolloff=8

" Open all folds by default
set foldlevelstart=20

set novisualbell

" a: A host of abbreviations
" t: Truncate file messages
" T: Truncate other messages
" I: No intro message
" A: no swap file annoyance
set shortmess=atTIA

" Highlight current line
if empty($CONEMUBUILD)
  set cursorline
endif

if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window (for an alternative on Windows, see simalt below).
  set lines=999 columns=999
endif

" For statusline
set encoding=utf-8 " Necessary to show Unicode glyphs
set laststatus=2   " Always show the statusline

if !has('nvim')
  set term=xterm
endif
if !has("gui_running")
  set t_Co=256
endif

" Invisible cursor too often :(
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=0

let &t_AB="\e[48;5;%dm"
let &t_AF="\e[38;5;%dm"

" no scrollbars
set guioptions-=m
set guioptions-=T
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R

" Color scheme
set background=dark

" needs base16-shell run
let base16colorspace=256
colorscheme base16-default

" Operators different from functions
hi Operator       ctermfg=2 guifg=#a1b56c
" String same as old comment
hi String         ctermfg=8 guifg=#585858
" String same as comment
hi Comment         ctermfg=8 guifg=#585858
" less distracting matching
hi MatchParen cterm=bold ctermbg=none ctermfg=none


" Split separator colors
set fillchars+=stlnc:-
set fillchars+=stl:-
hi VertSplit ctermfg=8 ctermbg=0 guifg=#93a1a1 guibg=#073642

" Search highlighting
hi Search term=bold,underline gui=bold,underline

" to play nicely with diminactive
hi NonText ctermbg=black

" Split vertically by default
cnoreabbrev sb vert sb
cnoreabbrev hsb sb

" To get the preview window at the bottom
set splitbelow
set splitright

" Less odd highlighting
autocmd BufEnter * :syntax sync fromstart

" Make quickfix at the bottom
autocmd FileType qf wincmd J

" Close quickfix if it's the last window
au BufEnter * call MyLastWindow()
function! MyLastWindow()
  " if the window is quickfix go on
  if &buftype=="quickfix"
    " if this window is last on screen quit without warning
    if winbufnr(2) == -1
      quit
    endif
  endif
endfunction

" Exit insert mode when focus is lose
function! PopOutOfInsertMode()
    if v:insertmode
        feedkeys("\<C-\>\<C-n>")
    endif
endfunction

autocmd FocusLost * call PopOutOfInsertMode()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" viminfo / shada
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Tell vim to remember certain things when we exit
"  '100  :  marks will be remembered for up to 10 previously edited files
"  "1000 :  will save up to 100 lines for each register
"  :200  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='1000,\"1000,:200,%,n~/.viminfo

set shada='1000,/1000,:1000,@1000

function! ResCur()
  if line("'\"") <= line("$")
    normal! g'"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Saving
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"
" Make directory for a file if it doesn't exist
"
function s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction

augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keymapping
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" escape in terminal mode
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
endif

" Set all the mouse options
set mouse=a

" Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
if has('nvim')
  tnoremap <C-J> <C-\><C-n><C-W><C-J>
  tnoremap <C-K> <C-\><C-n><C-W><C-K>
  tnoremap <C-L> <C-\><C-n><C-W><C-L>
  tnoremap <C-H> <C-\><C-n><C-W><C-H>
endif

" no Ex mode
nnoremap Q <Nop>

set backspace=indent,eol,start

let mapleader=" "

nnoremap ' `
nnoremap ` '

command Wq wq
command WQ wq
command Qw wq
command QW wq
command W w
command Q q

" sort
vnoremap <leader>r :sort<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set wildmode=list:longest

" Highlight search terms...
set nohlsearch
set incsearch " ...dynamically as they are typed.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim diminactive
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:diminactive_enable_focus = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CtrlP
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ctrlp find files
let g:ctrlp_by_filename = 1
set wildignore+=*/dist/*,*/tmp/*,*.so,*.swp,*.zip,*.hi,*.o
let g:ctrlp_extensions = ['tag']
noremap <C-T> :CtrlPTag<CR>
let g:ctrlp_switch_buffer = 0

let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ }


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Align
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vnoremap a= :Align =<CR>
vnoremap a- :Align -><CR>
vnoremap a: :Align ::<CR>
vnoremap a\| :Align \| \| =<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lightline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("mac")
  " Menlo as a MacOSX Font
  set guifont=Menlo:h11
elseif has("unix")
  set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 11
elseif has("win32")
  if has('nvim')
    command -nargs=? Guifont call rpcnotify(0, 'Gui', 'SetFont', "<args>") | let g:Guifont="<args>"
    " Set font on start
    let g:Guifont="DejaVu Sans Mono for Powerline:h9"
  else
    set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h9
  endif
endif

set noruler
set noshowmode

let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'obsession', 'readonly', 'filename', 'neomake_errors', 'neomake_warnings' ], ['ctrlpmark'] ],
      \   'right': [ [ 'lineinfo', 'syntastic' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [], [ 'readonly', 'filename'] ],
      \   'right': [ [ 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'MyFugitive',
      \   'filename': 'MyFilename',
      \   'fileformat': 'MyFileformat',
      \   'filetype': 'MyFiletype',
      \   'fileencoding': 'MyFileencoding',
      \   'mode': 'MyMode',
      \   'ctrlpmark': 'CtrlPMark',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \   'neomake_errors': 'neomake#statusline#LoclistErrors',
      \   'neomake_warnings': 'neomake#statusline#LoclistWarnings',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \   'neomake_errors': 'error',
      \   'neomake_warnings': 'warning',
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"":""}',
      \   'obsession': '%{ObsessionStatus()}',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }


function! MyModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = ' '  " edit here for cool mark
      let _ = fugitive#head()
      return strlen(_) ? mark._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 100 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 100 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 100 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP'
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" hlsl
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufNewFile,BufRead *.fx,*.fxc,*.fxh,*.hlsl set ft=hlsl


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Neocomplete
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !has('nvim')
  " Use neocomplete.
  let g:neocomplete#enable_at_startup = 1
  " Use smartcase.
  let g:neocomplete#enable_smart_case = 1
  " Set minimum syntax keyword length.
  let g:neocomplete#sources#syntax#min_keyword_length = 3
  let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

  " Plugin key-mappings.
  inoremap <expr><C-g>     neocomplete#undo_completion()
  inoremap <expr><C-l>     neocomplete#complete_common_string()

  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>

  function! s:my_cr_function()
    return neocomplete#close_popup() . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplete#close_popup()
  inoremap <expr><C-e>  neocomplete#cancel_popup()

  inoremap <expr><C-Space>  "<C-x><C-o><C-p>"

  " Enable heavy omni completion.
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif
  let g:neocomplete#sources#omni#input_patterns.haskell = '[^.[:digit:] *\t]\%(\.\)'

  set completeopt=longest,menuone

  " smartcase
  let g:neocomplete#enable_camel_case = 1
  let g:neocomplete#enable_fuzzy_completion = 1
else
  " Use deoplete.
  let g:deoplete#enable_at_startup = 1
  " Use smartcase.
  let g:deoplete#enable_ignore_case = 'ignorecase'
  let g:deoplete#enable_smart_case = 'infercase'
  let g:deoplete#data_directory = '~/.cache/deoplete/'

  let g:deoplete#auto_completion_start_length = 1
  let g:deoplete#disable_auto_complete = 0

  imap     <Nul> <C-Space>
  inoremap <expr><C-Space> deoplete#mappings#manual_complete()
  inoremap <expr><BS>      deoplete#mappings#smart_close_popup()."\<C-h>"

  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>

  function! s:my_cr_function()
    " return deoplete#close_popup() . "\<CR>"
    " For no inserting <CR> key.
    return pumvisible() ? deoplete#mappings#close_popup() : "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"

  set completeopt=longest,menuone
  set completeopt+=noinsert
  set completeopt+=noselect

endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" snippets
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Plugin key-mappings.
imap <C-s>     <Plug>(neosnippet_expand_or_jump)
smap <C-s>     <Plug>(neosnippet_expand_or_jump)
xmap <C-s>     <Plug>(neosnippet_expand_target)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set tabstop=2
set softtabstop=2
set expandtab
set shiftwidth=2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" easytags
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:easytags_suppress_ctags_warning = 1
let g:easytags_dynamic_files = 1
let g:easytags_cmd = ""
let g:easytags_updatetime_warn = 0
let g:easytags_async = 1
let g:easytags_ctags_version = ""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntastic
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_quiet_messages = { "regex": "#pragma once in main file" }
let g:syntastic_enable_async = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NeoMake
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup AutoNeomake
  autocmd!
  autocmd BufWritePost *.hs,*.lhs,*.c,*.cpp call s:neomake()
  autocmd BufReadPost *.hs,*.lhs,*.c,*.cpp call s:neomake()
augroup END

function! s:neomake()
  Neomake
  call lightline#update()
endfunction

function! s:GetBufferList()
  redir =>buflist
  silent! ls
  redir END
  return buflist
endfunction

function! s:PopulateQuickFixPerhaps()
  let l:l = len(getloclist(0))
  if (l == 0)
    cclose
  else
    call setqflist(getloclist(0))
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Unimpared
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>QFPrevious()
  try
    cprev
  catch /^Vim\%((\a\+)\)\=:E553/
    clast
  catch a:e
    throw a:e
  endtry
endfunction

function! <SID>QFNext()
  try
    cnext
  catch /^Vim\%((\a\+)\)\=:E553/
    cfirst
  catch a:e
    throw a:e
  endtry
endfunction

nnoremap <silent> <Plug>QFPrevious    :<C-u>exe 'call <SID>QFPrevious()'<CR>
nnoremap <silent> <Plug>QFNext        :<C-u>exe 'call <SID>QFNext()'<CR>
nmap <silent> <S-F8>    <Plug>QFPrevious
nmap <silent> <F8>    <Plug>QFNext

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim2hs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:haskell_conceal       = 0
let g:haskell_quasi         = 0
let g:haskell_interpolation = 0
let g:haskell_regex         = 0
let g:haskell_jmacro        = 0
let g:haskell_shqq          = 0
let g:haskell_sql           = 0
let g:haskell_json          = 0
let g:haskell_xml           = 0
let g:haskell_hsp           = 0
let g:haskell_tabular       = 0

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Haskell stuff
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:haskell_enable_quantification   = 1 " to enable highlighting of forall
let g:haskell_enable_recursivedo      = 1 " to enable highlighting of mdo and rec
let g:haskell_enable_arrowsyntax      = 1 " to enable highlighting of proc
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of pattern
let g:haskell_enable_typeroles        = 1 " to enable highlighting of type roles
let g:haskell_enable_static_pointers  = 1 " to enable highlighting of static
let g:haskell_indent_if               = 2
let g:haskell_indent_case             = 2
let g:haskell_indent_let              = 4
let g:haskell_indent_where            = 6
let g:haskell_indent_do               = 3
let g:haskell_indent_in               = 0

let g:necoghc_enable_detailed_browse = 1
let $PATH = $PATH . ':' . expand("~/.cabal/bin")

"
" ghc mod
"
let &l:statusline = '%{empty(getqflist()) ? "[No Errors]" : "[Errors Found]"}' . (empty(&l:statusline) ? &statusline : &l:statusline)

let g:ghcmod_hlint_options = ['--hint=HLint', '--hint=Default', '--hint=Dollar', '--cpp-define=HLINT', '--color']

if(s:use_ghc_mod)
  autocmd Filetype haskell nnoremap <buffer> <leader>i :GhcModInfo!<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>c :GhcModTypeClear<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>t :GhcModType!<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>T :GhcModTypeInsert!<CR>
else
  autocmd Filetype haskell nnoremap <buffer> <leader>i :HdevtoolsInfo<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>c :HdevtoolsClear<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>t :HdevtoolsType<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>T :HdevtoolsTypeInsert<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>d :HdevtoolsFindsymbol<CR>
endif

if(s:use_ghc_mod)
  let g:neomake_haskell_hdevtools_maker = {}
else
  let g:neomake_haskell_ghcmod_maker = {}
endif

" highlight long columns
au FileType haskell let &colorcolumn=join(range(81,999),",")

" Strip trailing whitespace
" automatically remove trailing whitespace before write
function! StripTrailingWhitespace()
  normal mZ
  %s/\s\+$//e
  if line("'Z") != line(".")
    echo "Stripped whitespace\n"
  endif
  normal `Z
endfunction

autocmd FileType * autocmd BufWritePre <buffer> :call StripTrailingWhitespace()
nnoremap <leader>s :call StripTrailingWhitespace()<CR>

autocmd FileType haskell let b:easytags_auto_highlight = 1

let g:easytags_languages = {
      \   'haskell': {
      \       'cmd': '~/.cabal/bin/lushtags',
      \       'args': [],
      \       'fileoutput_opt': '-f',
      \       'stdout_opt': '-f-',
      \       'recurse_flag': '-R'
      \   }
      \}

function! Preserve(command)
  let w = winsaveview()
  execute a:command
  call winrestview(w)
endfunction

" Format current function
autocmd FileType haskell map <leader>f :call Preserve("normal gqah")<CR>

let g:hindent_style="gibiansky"
let g:formatprg_haskell = "hindent"
let g:formatprg_args_haskell = "--style " . g:hindent_style . " --line-length 80"

function! FormatHaskell()
  if !empty(v:char)
    return 1
  else
    let l:filter = g:formatprg_haskell . " " . g:formatprg_args_haskell
    let l:command = v:lnum.','.(v:lnum+v:count-1).'!'.l:filter
    execute l:command
  endif
endfunction

autocmd FileType haskell setlocal formatexpr=FormatHaskell()

autocmd Filetype haskell setlocal omnifunc=necoghc#omnifunc
autocmd Filetype haskell setlocal iskeyword+=39
autocmd Filetype haskell setlocal iskeyword-=.

function! s:get_cabal_sandbox()
    if filereadable('cabal.sandbox.config')
        let l:output = system('cat cabal.sandbox.config | grep local-repo')
        let l:dir = matchstr(substitute(l:output, '\n', ' ', 'g'), 'local-repo: \zs\S\+\ze\/packages')
        return l:dir
    else
        return ''
    endif
endfunction

" Configuration for syntastic
let g:syntastic_haskell_checkers=['ghc_mod']

let ghc_args = ["Wall", "fno-warn-name-shadowing", "fno-warn-type-defaults"]
let sandbox = s:get_cabal_sandbox()
if len(sandbox) != 0
    let package_db = split(globpath(sandbox, "*-packages.conf.d"), '\n')[0]
    call add(ghc_args, 'package-db=' . package_db)
endif

call map(ghc_args, '"-g-" . v:val')
let ghc_args_string = join(ghc_args, ' ')

let g:syntastic_haskell_ghc_mod_args=ghc_args_string
let g:syntastic_haskell_hdevtools_args=ghc_args_string

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Clang complete
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Code from bairui@#vim.freenode
" https://gist.github.com/3322468
function! Flatten(list)
  let val = []
  for elem in a:list
    if type(elem) == type([])
      call extend(val, Flatten(elem))
    else
      call add(val, elem)
    endif
    unlet elem
  endfor
  return val
endfunction

let g:clang_library_path = expand('~/.nix-profile/lib/')

let g:neomake_c_clang_maker = neomake#makers#ft#c#clang()
if filereadable(".clang_complete")
  let s:clang_args = Flatten(map(readfile(".clang_complete"), "split(v:val)"))
else
  let s:clang_args = []
endif
let g:neomake_c_clang_maker.args += filter(s:clang_args, '!empty(v:val)')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Markdown
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd FileType markdown setlocal omnifunc=
