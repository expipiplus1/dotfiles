{ config, pkgs, ... }:

let
  appendPatches = patches: drv:
    drv.overrideAttrs (old: { patches = old.patches or [ ] ++ patches; });

  luaConfig = lua: ''
    lua <<EOF
    ${lua}
    EOF
  '';

in {
  programs.neovim = {
    enable = true;
    # package =
      # appendPatches [ ./nvim-backup-dir.patch ./nvim-backup-perms.patch ]
      # pkgs.neovim-unwrapped;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = fzf-vim;
        config = ''
          if $TMUX != ""
            let g:fzf_layout = { 'tmux': '-p80%,80%' }
          else
            let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6, 'border': 'sharp' } }
          endif

          let $FZF_DEFAULT_COMMAND='${pkgs.fd}/bin/fd --type f'
          nnoremap ; :FZF --preview bat\ --color=always\ {}<CR>
        '';
      }
      tmux-complete-vim
      (appendPatches [ ./plug-patches/cabal-module-word.patch ] haskell-vim)
      lessspace-vim
      {
        plugin = (nvim-treesitter.overrideAttrs (_old: {
          src = pkgs.fetchFromGitHub {
            owner = "nvim-treesitter";
            repo = "nvim-treesitter";
            rev = "e473630fe0872cb0ed97cd7085e724aa58bc1c84";
            sha256 = "1l6cv9znpwnk4hmg3vh8gy26s8hvlbg03wmd7snjwxcpfyj6vi84";
          };
          postPatch = let
            grammars =
              pkgs.tree-sitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
          in ''
            rm -r parser
            ln -s ${grammars} parser
          '';

        }));
        config = luaConfig ''
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
            },
          }
        '';
      }
      {
        plugin = open-browser-vim;
        config = ''
          " Disable netrw gx mapping.
          let g:netrw_nogx = get(g:, 'netrw_nogx', 1)
          nmap gx <Plug>(openbrowser-open)
          vmap gx <Plug>(openbrowser-open)
        '';
      }
      {
        plugin = (pkgs.vimUtils.buildVimPlugin {
          name = "tree-sitter-playground";
          src = pkgs.fetchFromGitHub {
            owner = "nvim-treesitter";
            repo = "playground";
            rev = "2715d35f27cbdfe6231e48212d12be383013f442";
            sha256 = "0z1vlsdmhlw6pbga9nypsihzjybglyr8is3maqbyqswrmz1yg87h";
          };
        });
        config = luaConfig ''
          require "nvim-treesitter.configs".setup {
            playground = {
              enable = true,
              disable = {},
              updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
              persist_queries = false, -- Whether the query persists across vim sessions
              keybindings = {
                toggle_query_editor = 'o',
                toggle_hl_groups = 'i',
                toggle_injected_languages = 't',
                toggle_anonymous_nodes = 'a',
                toggle_language_display = 'I',
                focus_language = 'f',
                unfocus_language = 'F',
                update = 'R',
                goto_node = '<cr>',
                show_help = '?',
              },
            }
          }
        '';
      }
      vim-abolish
      vim-easy-align
      vim-fugitive
      vim-gist
      vim-markdown
      vim-rhubarb
      {
        plugin = vim-nix;
        config = ''
          autocmd FileType nix setlocal formatprg=${pkgs.nixfmt}/bin/nixfmt
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
        ./plug-patches/vim-textobj-haskell-python3.patch
      ] vim-textobj-haskell)
      vim-textobj-user
      vim-tmux-focus-events
      vim-tmux-navigator
      vim-unimpaired
      vim-visual-increment
      vim-yaml
      {
        plugin = (base16-vim.overrideAttrs (_old: {
          src = pkgs.fetchFromGitHub {
            owner = "chriskempson";
            repo = "base16-vim";
            rev = "6191622d5806d4448fa2285047936bdcee57a098"; # pin
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
          highlight CocHighlightText gui=underline guibg=#282a2e cterm=underline ctermbg=10
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
