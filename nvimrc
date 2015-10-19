set nocompatible 
filetype off

if has('NVIM')
    let s:editor_root=expand("~/.nvim")
else
    let s:editor_root=expand("~/.vim")
endif

let &rtp = &rtp . ',' . s:editor_root 
if has('nvim')
  let &rtp = &rtp . ',' . expand("~/opt/bin/nvim")
endif

call plug#begin(s:editor_root . '/plugged')

Plug 'Chiel92/vim-autoformat'
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

Plug 'altercation/vim-colors-solarized'
Plug 'beyondmarc/hlsl.vim'
Plug 'itchyny/lightline.vim'
Plug 'kien/ctrlp.vim'

Plug 'Twinside/vim-hoogle'
Plug 'dag/vim2hs'
Plug 'eagletmt/ghcmod-vim'
Plug 'eagletmt/neco-ghc'
Plug 'eagletmt/unite-haddock'
Plug 'neovimhaskell/haskell-vim'

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
Plug 'vim-scripts/Align'
Plug 'xolox/vim-easytags'
Plug 'xolox/vim-misc'
Plug 'christoomey/vim-tmux-navigator'
Plug 'milkypostman/vim-togglelist'

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
  :silent !mkdir -p expand(s:editor_root . '/backup') >/dev/null 2>&1
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
  :silent !mkdir -p expand(s:editor_root . '/swap') >/dev/null 2>&1
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
    :silent !mkdir -p expand(s:editor_root . '/undo') > /dev/null 2>&1
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

set ruler

set scrolloff=8

" Open all folds by default
set foldlevelstart=20

set novisualbell

" a: A host of abbreviations
" t: Truncate file messages
" T: Truncate other messages
" I: No intro message
set shortmess=atTI

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
colorscheme solarized

" Search highlighting
hi Search term=bold,underline gui=bold,underline 
" hi CursorLine cterm=none ctermbg=11 guibg=Grey90

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Saving
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Tell vim to remember certain things when we exit
"  '100  :  marks will be remembered for up to 10 previously edited files
"  "1000 :  will save up to 100 lines for each register
"  :200  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='1000,\"1000,:200,%,n~/.viminfo

function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
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
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'readonly', 'filename'], ['ctrlpmark'] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [ 'fugitive', 'readonly', 'filename'] ],
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
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"":""}',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }


function! MyModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help' && &readonly ? 'RO' : ''
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = ''  " edit here for cool mark
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
  "inoremap <expr><C-Space>  neocomplete#start_manual_complete()
  
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

  " let g:deoplete#sources = {}
  " let g:deoplete#sources.haskell = []

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
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

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
" let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_quiet_messages = { "regex": "#pragma once in main file" }
let g:syntastic_enable_async = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NeoMake
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:neomake_open_list = 2

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.hs,*.lhs,*.c,*.cpp call s:neomake()
  autocmd BufReadPost *.hs,*.lhs,*.c,*.cpp call s:neomake()
augroup END

function! s:neomake()
  Neomake
  call lightline#update()
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Unimpared 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>LocationPrevious()                       
  try                                                   
    lprev                                               
  catch /^Vim\%((\a\+)\)\=:E553/                        
    llast                                               
  endtry                                                
endfunction                                             

function! <SID>LocationNext()                           
  try                                                   
    lnext                                               
  catch /^Vim\%((\a\+)\)\=:E553/                        
    lfirst                                              
  endtry                                                
endfunction                                             

nnoremap <silent> <Plug>LocationPrevious    :<C-u>exe 'call <SID>LocationPrevious()'<CR>                                        
nnoremap <silent> <Plug>LocationNext        :<C-u>exe 'call <SID>LocationNext()'<CR>
nmap <silent> <S-F8>    <Plug>LocationPrevious              
nmap <silent> <F8>    <Plug>LocationNext

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim2hs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:haskell_conceal = 0


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Haskell stuff
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:necoghc_enable_detailed_browse = 1
let $PATH = $PATH . ':' . expand("~/.cabal/bin")

"
" ghc mod
"
let &l:statusline = '%{empty(getqflist()) ? "[No Errors]" : "[Errors Found]"}' . (empty(&l:statusline) ? &statusline : &l:statusline)
" autocmd BufWritePost *.hs GhcModCheckAndLintAsync
" autocmd BufWritePost *.lhs GhcModCheckAndLintAsync

let g:ghcmod_hlint_options = ['--hint=HLint', '--hint=Default', '--hint=Dollar', '--cpp-define=HLINT', '--color']

autocmd Filetype haskell nnoremap <buffer> <leader>i :GhcModInfo!<CR>
autocmd Filetype haskell nnoremap <buffer> <leader>c :GhcModTypeClear<CR>
autocmd Filetype haskell nnoremap <buffer> <leader>t :GhcModType!<CR>
autocmd Filetype haskell nnoremap <buffer> <leader>T :GhcModTypeInsert!<CR>
" autocmd FileType haskell map <leader>i :HdevtoolsInfo<CR>
" autocmd FileType haskell map <leader>t :HdevtoolsType<CR>
" autocmd FileType haskell map <leader>T :HdevtoolsClear<CR>

" highlight long columns
au FileType haskell let &colorcolumn=join(range(101,999),",")
highlight ColorColumn ctermbg=7 guibg=#2c2d27

" Strip trailing whitespace
autocmd FileType haskell,lhaskell autocmd BufWritePre <buffer> :%s/\s\+$//e

autocmd FileType haskell let b:easytags_auto_highlight = 1
"let g:easytags_languages = {
"      \   'haskell': {
"      \     'cmd': 'hasktags',
"      \       'args': ['-c'],
"      \       'fileoutput_opt': '-f',
"      \       'stdout_opt': '-f-',
"      \       'recurse_flag': ''
"      \   }
"      \}

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
let g:formatprg_args_haskell = "--style " . g:hindent_style . " --line-length 100"

autocmd Filetype haskell setlocal omnifunc=necoghc#omnifunc
autocmd Filetype haskell setlocal iskeyword+=39

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
" let g:syntastic_haskell_checkers=['hdevtools', 'hlint']

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" Temporary hack
"

"let g:python3_host_prog='/nix/store/lwz7kmb4jzgh3da04p1pa723i6084xk0-python3-3.4.3/bin/python3'
