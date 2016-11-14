set nocompatible

if has('NVIM')
    let s:editor_root=expand("~/.config/nvim")
else
    let s:editor_root=expand("~/.vim")
endif

let &rtp = &rtp . ',' . s:editor_root
if has('nvim')
  let &rtp = &rtp . ',' . expand("~/opt/bin/nvim")
endif

let s:use_ghc_mod = 0

function! BuildComposer(info)
  if a:info.status != 'unchanged' || a:info.force
    !cargo build --release
    UpdateRemotePlugins
  endif
endfunction

function! BuildClangComplete(info)
  if a:info.status != 'unchanged' || a:info.force
    !make
    UpdateRemotePlugins
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" neovim fixes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" from https://github.com/neovim/neovim/issues/2017#issuecomment-75235455
set timeout

"NeoVim handles ESC keys as alt+key, set this to solve the problem
if has('nvim')
 set ttimeout
 set ttimeoutlen=0
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Commentary
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType vhdl setlocal commentstring=--\ %s
autocmd FileType vhdl setlocal comments=:--

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Comments
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Comment continuation
autocmd FileType * setlocal formatoptions+=c formatoptions+=r formatoptions+=o

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
  call mkdir(s:editor_root . '/backup', 'p')
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
  call mkdir(s:editor_root . '/swap', 'p')
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
    call mkdir(s:editor_root . '/undo', 'p')
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
set shortmess=atTI

" Highlight current line
set cursorline

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

let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

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
if empty(glob("~/.config/light"))
  set background=dark
else
  set background=light
endif

" needs base16-shell run
let base16colorspace=256
colorscheme base16-tomorrow

" Operators different from functions
hi Operator       ctermfg=2 guifg=#a1b56c
" String same as old comment
hi String         ctermfg=8 guifg=#585858
" String same as comment
hi Comment         ctermfg=8 guifg=#585858
" less distracting matching
hi MatchParen cterm=bold ctermbg=none ctermfg=none
" Blue types
hi Type ctermfg=4 guifg=#268bd2
" purple imports
hi Include ctermfg=5 guifg=#6c71c4

" to play nicely with diminactive make it the same as cursorline
if &background == "light"
  hi NonText ctermbg=21 guibg=#e0e0e0
else
  hi NonText ctermbg=18 guibg=#282a2e
endif


" Split separator colors
set fillchars+=stlnc:-
set fillchars+=stl:-
hi VertSplit ctermfg=8 ctermbg=0 guifg=#93a1a1 guibg=#073642

" Search highlighting
hi Search term=bold,underline gui=bold,underline

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
" vim prev_indent
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

imap <silent> <C-d> <Plug>PrevIndent
nmap <silent> <C-g><C-g> :PrevIndent<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Fuzzy
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:fuzzy_rootcmds = [
\ 'upfind -d ''.*\.cabal''',
\ 'upfind -d build.hs',
\ 'git rev-parse --show-toplevel',
\ 'hg root'
\ ]

nnoremap <C-p> :FuzzyOpen<CR>


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

  " Don't squash types
  call deoplete#custom#set('_', 'converters', [])

  let g:deoplete#auto_completion_start_length = 1
  let g:deoplete#disable_auto_complete = 0

  imap     <Nul> <C-Space>
  inoremap <expr><C-Space> deoplete#mappings#manual_complete()
  inoremap <expr><BS>      deoplete#mappings#smart_close_popup()."\<C-h>"

  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return deoplete#mappings#smart_close_popup() . "\<CR>"
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

let g:neomake_verbose=0
let g:neomake_warning_sign = {
      \ 'text': '❯',
      \ 'texthl': 'String',
      \ }
let g:neomake_error_sign = {
      \ 'text': '❯',
      \ 'texthl': 'ErrorMsg',
      \ }

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

"
" stylish-haskell
"
augroup stylish-haskell
  autocmd!
  autocmd BufWritePost *.hs silent call StylishHaskell()
augroup END

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
  let g:hdevtools_options = '-g-Wall -g-isrc -g-itest -g-fbyte-code'

  autocmd Filetype haskell nnoremap <buffer> <leader>i :HdevtoolsInfo<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>c :HdevtoolsClear<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>t :HdevtoolsType<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>T :HdevtoolsSig<CR>
  autocmd Filetype haskell nnoremap <buffer> <leader>d :HdevtoolsFindsymbol<CR>
endif

if(s:use_ghc_mod)
  let g:neomake_haskell_enabled_makers = ['ghcmod', 'hlint']
else
  let g:neomake_haskell_enabled_makers= ['hdevtools', 'hlint']
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" hlint-refactor-vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:hlintRefactor#disableDefaultKeybindings = 1

map <silent> <leader>e :call ApplyOneSuggestion()<CR>
map <silent> <leader>E :call ApplyAllSuggestions()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" pointfree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" See :help :visual_example
" This splits before and after the selection to create a new line, deindents
" the new lines, runs pointfree over the middle and joins it all up again.
xnoremap <silent> <leader>p <Esc>`>a<CR><Esc>:left<CR>`<i<CR><Esc>:left<CR>V:!pointfree --stdin<CR>kgJgJ
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Clang complete
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:clang_complete_auto = 0
let g:clang_auto_select = 0
let g:clang_omnicppcomplete_compliance = 1
let g:clang_make_default_keymappings = 0
let g:clang_snippets=1
let g:clang_snippets_engine="clang_complete"

let g:clang_use_library = 1
let g:clang_library_path = expand('~/.nix-profile/lib/')

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

let g:neomake_c_clang_maker = neomake#makers#ft#c#clang()
if filereadable(".clang_complete")
  let s:clang_args = Flatten(map(readfile(".clang_complete"), "split(v:val)"))
else
  let s:clang_args = []
endif
let g:neomake_c_clang_maker.args += filter(s:clang_args, '!empty(v:val)')

let g:neomake_cpp_clang_maker = neomake#makers#ft#cpp#clang()
let g:neomake_cpp_clang_maker.args += filter(s:clang_args, '!empty(v:val)')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" clang-format
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:clang_format#auto_formatexpr=1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Markdown
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd FileType markdown setlocal omnifunc=

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Digraphs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ∘
digraphs oo 8728
digraphs [] 9744
digraphs [x 9745

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Table mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:table_mode_corner="|"

