{ config, pkgs, ... }:

let
  appendPatches = patches: drv:
    drv.overrideAttrs (old: { patches = old.patches or [ ] ++ patches; });

  pluginsWithConfig = with pkgs.vimPlugins; [
    {
      plugin = (base16-vim.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "expipiplus1";
          repo = "base16-vim";
          rev = "9daeb991ee51977c3deea4b45846abfab34e9439";
          sha256 = "0n9pcpam15vrnjdl3ghlsr02kldwzi4dlb1w2mwfi57fp65akbnd";
        };
      }));
      config = ''
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
        if &background == "light"
          hi VertSplit ctermfg=0 ctermbg=21
        else
          hi VertSplit ctermfg=8 ctermbg=18
        endif

        " Column marker color
        if &background == "light"
          hi ColorColumn ctermbg=21 guibg=#e0e0e0
        else
          hi ColorColumn ctermbg=18 guibg=#282a2e
        endif

        " Search highlighting
        hi Search term=bold,underline gui=bold,underline
      '';
    }
    fzf-vim
    {
      plugin = ncm2;
      config = ''
        " enable ncm2 for all buffers
        autocmd BufEnter * call ncm2#enable_for_buffer()

        " suppress the annoying 'match x of y', 'The only match' and 'Pattern not
        " found' messages
        set shortmess+=c

        " IMPORTANT: :help Ncm2PopupOpen for more information
        set completeopt=noinsert,menuone,noselect

        set pumheight=10

        " Use <TAB> to select the popup menu:
        inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

        imap <silent><expr> <C-Space>
        		\ pumvisible() ?  "\<C-n>" :
        		\ "\<Plug>(ncm2_manual_trigger)"
      '';
    }
    ncm2-path
    ncm2-bufword
    tmux-complete-vim
    gist-vim
    (appendPatches [ ./plug-patches/cabal-module-word.patch ] haskell-vim)
    {
      plugin = hlint-refactor-vim;
      config = ''
        let g:hlintRefactor#disableDefaultKeybindings = 1
        map <silent> <nowait> <leader>e :call ApplyOneSuggestion()<CR>
        map <silent> <nowait> <leader>E :call ApplyAllSuggestions()<CR>
      '';
    }
    lessspace-vim
    {
      plugin = lightline-vim;
      config = ''
        set noruler
        set noshowmode

        let g:lightline = {
              \ 'colorscheme': 'solarized',
              \ 'active': {
              \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'readonly', 'filename' ], [] ],
              \   'right': [ [ 'lineinfo' ], ['percent'], ['filetype' ] ]
              \ },
              \ 'inactive': {
              \   'left': [ [], [ 'readonly', 'filename'] ],
              \   'right': [ [ 'lineinfo' ], ['percent'], [ 'filetype' ] ]
              \ },
              \ 'component_function': {
              \   'fugitive': 'MyFugitive',
              \   'filename': 'MyFilename',
              \   'filetype': 'MyFiletype',
              \ },
              \ 'component': {
              \   'readonly': '%{&readonly?"":""}',
              \ }
              \ }

        function! MyModified()
          return &ft =~ 'help' ? "" : &modified ? '+' : &modifiable ? "" : '-'
        endfunction

        function! MyFilename() abort
          let name = fnamemodify(expand("%"), ":~:.")
          let name = name !=# "" ? name : '[No Name]'
          let name = name . ("" != MyModified() ? ' ' . MyModified() : "")
          let threshold = winwidth(0) - 40
          let short = pathshorten(name)
          if len(name) < threshold
            return name
          elseif len(short) < threshold
            return short
          else
            return '<'.short[len(short)-threshold:]
          endif
        endfunction

        function! MyFugitive()
          try
            if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
              let mark = ' '  " edit here for cool mark
              let _ = fugitive#head()
              return strlen(_) ? mark._ : ""
            endif
          catch
          endtry
          return ""
        endfunction

        function! MyFiletype()
          return winwidth(0) > 100 ? (strlen(&filetype) ? &filetype : 'no ft') : ""
        endfunction
      '';
    }
    {
      plugin = neovim-fuzzy;
      config = ''
        let g:fuzzy_rootcmds = [
        \ '${pkgs.upfind}/bin/upfind -d build.hs',
        \ '${pkgs.upfind}/bin/upfind -d Main.mu',
        \ '${pkgs.upfind}/bin/upfind -d CMakeLists.txt',
        \ '${pkgs.upfind}/bin/upfind -d Makefile',
        \ '${pkgs.upfind}/bin/upfind -d "".+\.cabal""',
        \ '${config.programs.git.package}/bin/git rev-parse --show-toplevel',
        \ '${pkgs.mercurial}/bin/hg root'
        \ ]

        nnoremap <C-p> :FuzzyOpen<CR>
      '';
    }
    open-browser-vim
    open-browser-github-vim
    {
      plugin = prev_indent;
      config = ''
        imap <silent> <C-d> <Plug>PrevIndent
        nmap <silent> <C-g><C-g> :PrevIndent<CR>
      '';
    }
    vim-abolish
    {
      plugin = vim-commentary;
      config = ''
        autocmd FileType vhdl setlocal commentstring=--\ %s
        autocmd FileType vhdl setlocal comments=:--
        autocmd FileType cpp setlocal commentstring=//\ %s
        autocmd FileType cpp setlocal comments=://
        autocmd FileType c setlocal commentstring=//\ %s
        autocmd FileType c setlocal comments=://
      '';
    }
    {
      plugin = vim-diminactive;
      config = ''
        let g:diminactive_enable_focus = 1
      '';
    }
    vim-easy-align
    vim-fugitive
    vim-rhubarb
    vim-markdown
    vim-nix
    vim-repeat
    {
      plugin = vim-startify;
      config = ''
        let g:startify_change_to_dir = 0
        let g:startify_change_to_vcs_root = 0
      '';
    }
    vim-surround
    {
      plugin = vim-table-mode;
      config = ''
        let g:table_mode_corner="|"
        autocmd Filetype * nnoremap <nowait> <buffer> <leader>m :TableModeToggle<CR>
      '';
    }
    vim-textobj-function
    (appendPatches [
      ./plug-patches/vim-textobj-haskell-typesig.patch
      ./plug-patches/vim-textobj-haskell-end.patch
    ] vim-textobj-haskell)
    vim-textobj-user
    vim-tmux-focus-events
    vim-tmux-navigator
    vim-togglelist
    vim-unimpaired
    vim-visual-increment
    vim-yaml
    {
      plugin = LanguageClient-neovim;
      config = ''
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
      '';
    }
  ];

  pluginConfig = p:
    if builtins.hasAttr "plugin" p && builtins.hasAttr "config" p then ''
      """"""""""""""""""""""""""""""""
      " ${p.plugin.pname}
      """"""""""""""""""""""""""""""""
      ${p.config}
    '' else
      "";

in {
  programs.neovim = {
    enable = true;
    package = appendPatches [ ./nvim-backupdir.patch ] pkgs.neovim-unwrapped;
    vimAlias = true;
    plugins = map (p: p.plugin or p) pluginsWithConfig;
    extraConfig = builtins.readFile ./init.vim
      + pkgs.lib.concatMapStrings pluginConfig pluginsWithConfig;
  };
}
