{ config, pkgs, ... }:

let
  appendPatches = patches: drv:
    drv.overrideAttrs (old: { patches = old.patches or [ ] ++ patches; });

  pluginsWithConfig = with pkgs.vimPlugins; [
    (base16-vim.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "expipiplus1";
        repo = "base16-vim";
        rev = "9daeb991ee51977c3deea4b45846abfab34e9439";
        sha256 = "0n9pcpam15vrnjdl3ghlsr02kldwzi4dlb1w2mwfi57fp65akbnd";
      };
    }))
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
    neovim-fuzzy
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
    vim-startify
    vim-surround
    vim-table-mode
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
    LanguageClient-neovim
  ];

in {
  programs.neovim = {
    enable = true;
    package = appendPatches [ ./nvim-backupdir.patch ] pkgs.neovim-unwrapped;
    vimAlias = true;
    plugins = map (p: p.plugin or p) pluginsWithConfig;
    extraConfig = builtins.readFile ./init.vim
      + pkgs.lib.concatMapStrings (p: p.config or "") pluginsWithConfig;
  };
}
