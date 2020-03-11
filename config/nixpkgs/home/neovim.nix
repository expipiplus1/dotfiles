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
      tmux-complete-vim
      gist-vim
      (appendPatches [ ./plug-patches/cabal-module-word.patch ] haskell-vim)
      lessspace-vim
      vim-abolish
      vim-easy-align
      vim-fugitive
      vim-rhubarb
      vim-markdown
      {
        plugin = vim-nix;
        config = ''
          autocmd FileType nix setlocal formatprg=nixfmt
        '';
      }
      vim-repeat
      {
        plugin = vim-signify;
        config = ''
          let g:signify_disable_by_default = 1
        '';
      }
      vim-surround
      vim-textobj-function
      (appendPatches [
        ./plug-patches/vim-textobj-haskell-typesig.patch
        ./plug-patches/vim-textobj-haskell-end.patch
      ] vim-textobj-haskell)
      vim-textobj-user
      vim-tmux-focus-events
      vim-tmux-navigator
      vim-unimpaired
      vim-visual-increment
      vim-yaml
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
          if 1
            set t_8f=^[[38;2;%lu;%lu;%lum
            set t_8b=^[[48;2;%lu;%lu;%lum
            set termguicolors
            " Fancy windows and popups
            set pumblend=10
            set winblend=10
          else
            " needs base16-shell run
            let base16colorspace=256
          endif

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

          hi! def link String Comment

          exec "hi ConId ctermfg=" . 4 . " guifg=" . g:terminal_color_4
          exec "hi Operator ctermfg=" . 10 . " guifg=" . g:terminal_color_10
          exec "hi Statement gui=none"
          hi! def link Character String

          " less distracting matching
          hi MatchParen cterm=bold gui=bold guibg=none guifg=none ctermbg=none ctermfg=none

          " Search highlighting
          hi Search term=bold,underline gui=bold,underline

          hi! def link VertSplit StatusLineNC

          hi! def link CocErrorSign ErrorMsg
          hi! def link CocErrorSign ErrorMsg
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
                \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'readonly' ], ['filename' ], [ 'cocstatus' ] ],
                \   'right': [ [ 'lineinfo' ], [ 'percent'], ['filetype' ] ]
                \ },
                \ 'inactive': {
                \   'left': [ [], [ 'readonly', 'filename'] ],
                \   'right': [ [ 'lineinfo' ], ['percent'], [ 'filetype' ] ]
                \ },
                \ 'component_function': {
                \   'fugitive': 'MyFugitive',
                \   'filename': 'MyFilename',
                \   'filetype': 'MyFiletype',
                \   'cocstatus': 'coc#status',
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
                let mark = 'ᚠ '  " edit here for cool mark
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
              "${pkgs.upfind}/bin/upfind -d default.nix"
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
    extraConfig = ''
      source ${
        pkgs.substituteAll {
          src = ./init.vim;
          shortcut = config.programs.tmux.shortcut;
        }
      }
    '';
  };
}
