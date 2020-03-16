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

function! BuildComposer(info)
  if a:info.status != 'unchanged' || a:info.force
    !cargo build --release
    UpdateRemotePlugins
  endif
endfunction

function! BuiddClangComplete(info)
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

if has('nvim')
  set inccommand=nosplit
endif

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Comments
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Comment continuation
autocmd FileType * setlocal formatoptions+=c formatoptions+=r formatoptions-=o

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
set cursorline

" For statusline
set encoding=utf-8 " Necessary to show Unicode glyphs
set laststatus=2   " Always show the statusline

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

if has('nvim')
  set shada='1000,/1000,:1000,@1000
endif

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
if has("nvim")
  au TermOpen * tnoremap <Esc> <c-\><c-n>
  au FileType fzf tunmap <Esc>
endif

" Set all the mouse options
set mouse=a

" Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <C-@shortcut@> <C-w>
nnoremap <C-w> <nop>

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
command E e

" sort
vnoremap <nowait> <leader>r :sort<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set wildmenu
set wildmode=longest:full,full

" Highlight search terms...
set nohlsearch
set incsearch " ...dynamically as they are typed.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set tabstop=2
set softtabstop=2
set expandtab
set shiftwidth=2

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

"
" stylish-haskell
"

function s:myStylishHaskell()
  let s=system("git author " . @%)
  if v:shell_error || !empty(matchstr(s, ".*ermaszewski.*"))
    call StylishHaskell()
  endif
endfunction

let s:stylish_haskell_config = systemlist("upfind --fixed .stylish-haskell")

if len(s:stylish_haskell_config) != 0
  let g:stylish_haskell_args = "--config " . s:stylish_haskell_config[0]
endif

" augroup stylish-haskell
"   autocmd!
"   autocmd BufWritePost *.hs silent call s:myStylishHaskell()
" augroup END

" highlight long columns
au FileType haskell let &colorcolumn=join(range(81,81),",")

function! Preserve(command)
  let w = winsaveview()
  execute a:command
  call winrestview(w)
endfunction

" Format current function
autocmd FileType haskell map <nowait> <leader>f :call Preserve("normal gqah")<CR>

" Insert header
" TODO remove duplication here lol
autocmd FileType haskell map <nowait> <leader>h <ESC>:set paste<CR><ESC>o<ESC>64a-<ESC>o--<ESC>o<ESC>64a-<ESC>:set nopaste<CR>kA<space>
autocmd FileType vim map <nowait> <leader>h <ESC>:set paste<CR><ESC>o<ESC>64a"<ESC>o"<ESC>o<ESC>64a"<ESC>:set nopaste<CR>kA<space>
autocmd FileType cpp map <nowait> <leader>h <ESC>:set paste<CR><ESC>o<ESC>64a/<ESC>o//<ESC>o<ESC>64a//<ESC>:set nopaste<CR>kA<space>
autocmd FileType sh map <nowait> <leader>h <ESC>:set paste<CR><ESC>o<ESC>64a#<ESC>o#<ESC>o<ESC>64a#<ESC>:set nopaste<CR>kA<space>
autocmd FileType nix map <nowait> <leader>h <ESC>:set paste<CR><ESC>o<ESC>64a#<ESC>o#<ESC>o<ESC>64a#<ESC>:set nopaste<CR>kA<space>

let s:use_hindent=0
if(s:use_hindent)
  let g:hindent_style="gibiansky"
  let g:formatprg_haskell = "hindent"
  let g:formatprg_args_haskell = "--style " . g:hindent_style . " --line-length 80"
else
  let g:formatprg_haskell = "brittany"
  let g:formatprg_args_haskell = "--columns 80 --indent 2"
endif

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
" Ag
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

map <silent> <nowait> <leader>a :Ag<space>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" pointfree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" See :help :visual_example
" This splits before and after the selection to create a new line, deindents
" the new lines, runs pointfree over the middle and joins it all up again.
xnoremap <silent> <nowait> <leader>p <Esc>`>a<CR><Esc>:left<CR>`<i<CR><Esc>:left<CR>V:!pointfree --stdin<CR>kgJgJ

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Digraphs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ∘
digraphs oo 8728
" ☐
digraphs [] 9744
" ☑
digraphs [x 9745

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Spellcheck
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd Filetype * nnoremap <nowait> <buffer> <leader>p <ESC>1z=e

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Write faster
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <Leader>s :write<CR>
noremap <Leader>S :wall<CR>
noremap <Leader>q :quit<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" formatting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap g= :call Preserve("normal gggqG")<CR>:echo "file formatted"<CR>
