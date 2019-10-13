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

if &background == "light"
  hi QuickFixLine ctermbg=21 guibg=#e0e0e0
else
  hi QuickFixLine ctermbg=18 guibg=#282a2e
endif

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
vnoremap <nowait> <leader>r :sort<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set wildmode=list:longest

" Highlight search terms...
set nohlsearch
set incsearch " ...dynamically as they are typed.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Fuzzy
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:fuzzy_rootcmds = [
\ 'upfind -d build.hs',
\ 'upfind -d Main.mu',
\ 'upfind -d CMakeLists.txt',
\ 'upfind -d Makefile',
\ 'upfind -d ''.+\.cabal''',
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" snippets
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Plugin key-mappings.
imap <C-s>     <Plug>(neosnippet_expand_or_jump)
smap <C-s>     <Plug>(neosnippet_expand_or_jump)
xmap <C-s>     <Plug>(neosnippet_expand_target)

" This makes <| and |> into syntax high lighting delimeters, which is bad for
" Haskell code.
let g:neosnippet#enable_conceal_markers=0

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set tabstop=2
set softtabstop=2
set expandtab
set shiftwidth=2

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

"
" ghc mod
"
let &l:statusline = '%{empty(getqflist()) ? "[No Errors]" : "[Errors Found]"}' . (empty(&l:statusline) ? &statusline : &l:statusline)

let g:ghcmod_hlint_options = ['--hint=HLint', '--hint=Default', '--hint=Dollar', '--cpp-define=HLINT', '--color']

if(s:use_ghc_mod)
  autocmd Filetype haskell nnoremap <buffer> <nowait> <leader>i :GhcModInfo!<CR>
  autocmd Filetype haskell nnoremap <buffer> <nowait> <leader>c :GhcModTypeClear<CR>
  autocmd Filetype haskell nnoremap <buffer> <nowait> <leader>t :GhcModType!<CR>
  autocmd Filetype haskell nnoremap <buffer> <nowait> <leader>T :GhcModTypeInsert!<CR>
else
  let g:hdevtools_options = '-g-Wall -g-isrc -g-itest -g-fbyte-code'

  autocmd Filetype haskell nnoremap <buffer> <nowait> <leader>i :HdevtoolsInfo<CR>
  autocmd Filetype haskell nnoremap <buffer> <nowait> <leader>c :HdevtoolsClear<CR>
  autocmd Filetype haskell nnoremap <buffer> <nowait> <leader>t :HdevtoolsType<CR>
  autocmd Filetype haskell nnoremap <buffer> <nowait> <leader>T :HdevtoolsSig<CR>
  autocmd Filetype haskell nnoremap <buffer> <nowait> <leader>d :HdevtoolsFindsymbol<CR>
endif

if(s:use_ghc_mod)
  let g:neomake_haskell_enabled_makers = ['ghcmod', 'hlint']
else
  let g:neomake_haskell_enabled_makers= ['hdevtools', 'hlint']
endif

" highlight long columns
au FileType haskell let &colorcolumn=join(range(81,81),",")
if &background == "light"
  hi ColorColumn ctermbg=21 guibg=#e0e0e0
else
  hi ColorColumn ctermbg=18 guibg=#282a2e
endif

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
autocmd FileType haskell map <nowait> <leader>f :call Preserve("normal gqah")<CR>

" Insert header
autocmd FileType haskell map <nowait> <leader>h <ESC>:set paste<CR><ESC>o<ESC>64a-<ESC>o--<ESC>o<ESC>64a-<ESC>:set nopaste<CR>kA<space>
autocmd FileType vim map <nowait> <leader>h <ESC>:set paste<CR><ESC>o<ESC>64a"<ESC>o"<ESC>o<ESC>64a"<ESC>:set nopaste<CR>kA<space>
autocmd FileType cpp map <nowait> <leader>h <ESC>:set paste<CR><ESC>o<ESC>64a/<ESC>o//<ESC>o<ESC>64a//<ESC>:set nopaste<CR>kA<space>

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
" Language server
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:LanguageClient_serverCommands = {
  \ 'haskell': ['hie', '--lsp'],
  \ }

map <Leader>ll :call LanguageClient_contextMenu()<CR>
map <Leader>lk :call LanguageClient#textDocument_hover()<CR>
map <Leader>lg :call LanguageClient#textDocument_definition()<CR>
map <Leader>lr :call LanguageClient#textDocument_rename()<CR>
map <Leader>lf :call LanguageClient#textDocument_rangeFormatting()<CR>
map <Leader>ld :call LanguageClient#textDocument_formatting()<CR>
map <Leader>lb :call LanguageClient#textDocument_references()<CR>
map <Leader>la :call LanguageClient#textDocument_codeAction()<CR>
map <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>
map <Leader>lh :call LanguageClient#textDocument_documentHighlight()<CR>
map <Leader>le :call LanguageClient#workspace_applyEdit()<CR>
nnoremap <nowait> <leader>R :call LanguageClient#textDocument_rename()<CR>

" Rename - rn => rename
noremap <leader>rn :call LanguageClient#textDocument_rename()<CR>

" Rename - rc => rename camelCase
noremap <leader>rc :call LanguageClient#textDocument_rename(
            \ {'newName': Abolish.camelcase(expand('<cword>'))})<CR>

" Rename - rs => rename snake_case
noremap <leader>rs :call LanguageClient#textDocument_rename(
            \ {'newName': Abolish.snakecase(expand('<cword>'))})<CR>

" Rename - ru => rename UPPERCASE
noremap <leader>ru :call LanguageClient#textDocument_rename(
            \ {'newName': Abolish.uppercase(expand('<cword>'))})<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-better-whitespace
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Don't highlight whitespace
let g:better_whitespace_enabled=0
let g:strip_whitespace_on_save=1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Write faster
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <Leader>s :write<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SCB
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

au BufRead,BufNewFile *.mu set filetype=haskell

set guicursor=
