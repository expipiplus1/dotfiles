{ config, pkgs, lib, ... }:

let
  appendPatches = patches: drv:
    drv.overrideAttrs (old: { patches = old.patches or [ ] ++ patches; });

in {
  programs.neovim = {
    enable = true;
    package =
      appendPatches [ ./nvim-backup-dir.patch ./nvim-backup-perms.patch ]
      pkgs.neovim-unwrapped;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      fzf-vim
      # ncm2-path
      # ncm2-bufword
      tmux-complete-vim
      gist-vim
      (appendPatches [ ./plug-patches/cabal-module-word.patch ] haskell-vim)
      lessspace-vim
      vim-abolish
      vim-easy-align
      vim-fugitive
      vim-rhubarb
      vim-markdown
      vim-nix
      vim-repeat
      vim-surround
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
      # {
      #   plugin = ncm2;
      #   config = ''
      #     " enable ncm2 for all buffers
      #     autocmd BufEnter * call ncm2#enable_for_buffer()

      #     " suppress the annoying 'match x of y', 'The only match' and 'Pattern not
      #     " found' messages
      #     set shortmess+=c

      #     " IMPORTANT: :help Ncm2PopupOpen for more information
      #     set completeopt=noinsert,menuone,noselect

      #     set pumheight=10

      #     " Use <TAB> to select the popup menu:
      #     inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
      #     inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

      #     imap <silent><expr> <C-Space>
      #     		\ pumvisible() ?  "\<C-n>" :
      #     		\ "\<Plug>(ncm2_manual_trigger)"
      #   '';
      # }
      {
        plugin = (base16-vim.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            owner = "chriskempson";
            repo = "base16-vim";
            rev = "6191622d5806d4448fa2285047936bdcee57a098";
            sha256 = "1qz21jizcy533mqk9wff1wqchhixkcfkysqcqs0x35wwpbri6nz8";
          };
        }));
        config = ''
          set t_8f=^[[38;2;%lu;%lu;%lum
          set t_8b=^[[48;2;%lu;%lu;%lum
          set termguicolors

          " needs base16-shell run
          " let base16colorspace=256

          " Color scheme
          if empty(glob("~/.config/light"))
            set background=dark
            colorscheme base16-tomorrow-night
            let lightLineColorScheme = "Tomorrow_Night"
          else
            set background=light
            colorscheme base16-solarized-light
            let lightLineColorScheme = "solarized"
          endif

          exec "hi String ctermfg=" . base16_cterm03 . " guifg=#" . base16_gui03
          exec "hi ConId ctermfg=" . 4 . " guifg=" . g:terminal_color_4
          exec "hi Operator ctermfg=" . 10 . " guifg=" . g:terminal_color_10
          exec "hi Statement gui=none"
          hi! def link Character String

          " less distracting matching
          hi MatchParen cterm=bold gui=bold ctermbg=none ctermfg=none

          " Search highlighting
          hi Search term=bold,underline gui=bold,underline

          " Split separator colors
          set fillchars+=stlnc:-
          set fillchars+=stl:-

          hi! def link VertSplit StatusLineNC

          hi! def link CocErrorSign ErrorMsg

          " Fancy windows and popups
          set pumblend=10
          set winblend=10
        '';
      }
      {
        plugin = lightline-vim;
        config = ''
          set noruler
          set noshowmode

          let g:lightline = {
                \ 'colorscheme': lightLineColorScheme,
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
                \   'readonly': '%{&readonly?"r":""}',
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
          let g:fuzzy_rootcmds = [ ${
            lib.concatMapStringsSep ", " (s: "'${s}'")
            (lib.optionals (lib.hasAttr "upfind" pkgs) [
              "${pkgs.upfind}/bin/upfind -d build.hs"
              "${pkgs.upfind}/bin/upfind -d Main.mu"
              "${pkgs.upfind}/bin/upfind -d CMakeLists.txt"
              "${pkgs.upfind}/bin/upfind -d Makefile"
              ''${pkgs.upfind}/bin/upfind -d "".+\\.cabal""''
            ] ++ [
              "${config.programs.git.package}/bin/git rev-parse --show-toplevel"
            ])
          } ]

          nnoremap <C-p> :FuzzyOpen<CR>
        '';
      }
      {
        plugin = prev_indent;
        config = ''
          imap <silent> <C-d> <Plug>PrevIndent
          nmap <silent> <C-g><C-g> :PrevIndent<CR>
        '';
      }
      {
        plugin = vim-startify;
        config = ''
          let g:startify_change_to_dir = 0
          let g:startify_change_to_vcs_root = 0
        '';
      }
      {
        plugin = vim-table-mode;
        config = ''
          let g:table_mode_corner="|"
          autocmd Filetype * nnoremap <nowait> <buffer> <leader>m :TableModeToggle<CR>
        '';
      }
      {
        plugin = vim-diminactive;
        config = ''
          let g:diminactive_enable_focus = 1
        '';
      }
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
    ];
    extraConfig = builtins.readFile ./init.vim;
  };
}
