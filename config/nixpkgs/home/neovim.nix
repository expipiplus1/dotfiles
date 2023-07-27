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
      vim-strip-trailing-whitespace
      nvim-treesitter-textobjects
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = luaConfig ''
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
            },
          }
        '';
      }
      {
        plugin = nvim-treesitter-context;
        config = luaConfig ''
          require'treesitter-context'.setup{
            enable = true,
          }
        '' + ''
          hi! def link TreesitterContext StatusLine
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
          name = "neoscroll";
          src = pkgs.fetchFromGitHub {
            owner = "karb94";
            repo = "neoscroll.nvim";
            rev = "54c5c419f6ee2b35557b3a6a7d631724234ba97a";
            sha256 = "09xlpdkbi0rpyh18f80w77454krx65kw463rs12241f5m0bax7xb";
          };
        });
        config = luaConfig ''
          require('neoscroll').setup({
              -- All these keys will be mapped to their corresponding default scrolling animation
              mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>',
                          '<C-y>', '<C-e>', 'zt', 'zz', 'zb'},
              hide_cursor = true,          -- Hide cursor while scrolling
              stop_eof = true,             -- Stop at <EOF> when scrolling downwards
              respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
              cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
              easing_function = "circular",       -- Default easing function
              pre_hook = nil,              -- Function to run before the scrolling animation starts
              post_hook = nil,             -- Function to run after the scrolling animation ends
              performance_mode = false,    -- Disable "Performance Mode" on all buffers.
          })
        '';
      }
      # {
      #   plugin = (pkgs.vimUtils.buildVimPlugin {
      #     name = "tree-sitter-playground";
      #     src = pkgs.fetchFromGitHub {
      #       owner = "nvim-treesitter";
      #       repo = "playground";
      #       rev = "e6a0bfaf9b5e36e3a327a1ae9a44a989eae472cf";
      #       sha256 = "01smml755a1v09pfzg3zznr4hbxil0j8vqp8wxxb89ak1dipmjy2";
      #     };
      #   });
      #   config = luaConfig ''
      #     require "nvim-treesitter.configs".setup {
      #       playground = {
      #         enable = true,
      #         disable = {},
      #         updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      #         persist_queries = false, -- Whether the query persists across vim sessions
      #         keybindings = {
      #           toggle_query_editor = 'o',
      #           toggle_hl_groups = 'i',
      #           toggle_injected_languages = 't',
      #           toggle_anonymous_nodes = 'a',
      #           toggle_language_display = 'I',
      #           focus_language = 'f',
      #           unfocus_language = 'F',
      #           update = 'R',
      #           goto_node = '<cr>',
      #           show_help = '?',
      #         },
      #       }
      #     }
      #   '';
      # }
      {
        plugin = (pkgs.vimUtils.buildVimPlugin {
          name = "iswap";
          src = pkgs.fetchFromGitHub {
            owner = "mizlan";
            repo = "iswap.nvim";
            rev = "f4935e477c3dd8914a008884c4d83388d024487a";
            sha256 = "1zjwjmljns4pi578jm2f44gz3xxqfyk1bdfb8cnmxx23lg78n4vh";
          };
        });
        config = luaConfig ''
          require("iswap").setup({
            move_cursor = true,
          })
          vim.cmd[[
            nmap <leader>[ <Cmd>ISwapWithLeft<CR>
            nmap <leader>] <Cmd>ISwapWithRight<CR>
          ]]
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
      sleuth
      vim-surround
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
      {
        plugin = vim-visual-multi;
        config = ''
          let g:VM_maps = {}
          let g:VM_maps["Add Cursor Down"] = '<C-c>'
          let g:VM_theme = 'nord'
        '';
      }
      vim-yaml
      {
        plugin = nord-nvim;
        config = ''
          colorscheme nord

          let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
          let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
          set termguicolors

          " Fancy windows and popups
          set pumblend=10
          set winblend=10

          let lightLineColorScheme = "nord"

          hi! def link String Comment

          "     exec "hi ConId ctermfg=" . 4 . " guifg=" . g:terminal_color_4
          exec "hi Operator ctermfg=" . 10 . " guifg=" . g:terminal_color_10
          "     exec "hi Statement gui=none"
          "   hi! def link Character String

          "     " less distracting matching
          "     hi MatchParen cterm=bold gui=bold guibg=none guifg=none ctermbg=none ctermfg=none

          "     " Search highlighting
          "     hi Search term=bold,underline gui=bold,underline

          "     hi! def link VertSplit StatusLineNC

          "     hi! def link CocErrorSign ErrorMsg
          "     hi! def link CocErrorSign ErrorMsg
          "     highlight CocHighlightText gui=underline guibg=#282a2e cterm=underline ctermbg=10
          "     highlight CocHintHighlight cterm=none gui=none
          "     highlight CocInfoHighlight cterm=none gui=none
        '';
      }
      # {
      #   plugin = (base16-vim.overrideAttrs (_old: {
      #     src = pkgs.fetchFromGitHub {
      #       owner = "chriskempson";
      #       repo = "base16-vim";
      #       rev = "6191622d5806d4448fa2285047936bdcee57a098"; # pin
      #       sha256 = "1qz21jizcy533mqk9wff1wqchhixkcfkysqcqs0x35wwpbri6nz8";
      #     };
      #   }));
      #   config = ''
      #     if 1
      #       set t_8f=^[[38;2;%lu;%lu;%lum
      #       set t_8b=^[[48;2;%lu;%lu;%lum
      #       set termguicolors
      #       " Fancy windows and popups
      #       set pumblend=10
      #       set winblend=10
      #     else
      #       " needs base16-shell run
      #       let base16colorspace=256
      #     endif

      #     " Color scheme
      #     if empty(glob("~/.config/light"))
      #       set background=dark
      #       colorscheme base16-tomorrow-night
      #       let lightLineColorScheme = "Tomorrow_Night"
      #     else
      #       set background=light
      #       colorscheme base16-solarized-light
      #       let lightLineColorScheme = "solarized"
      #     endif

      #     hi! def link String Comment

      #     exec "hi ConId ctermfg=" . 4 . " guifg=" . g:terminal_color_4
      #     exec "hi Operator ctermfg=" . 10 . " guifg=" . g:terminal_color_10
      #     exec "hi Statement gui=none"
      #     hi! def link Character String

      #     " less distracting matching
      #     hi MatchParen cterm=bold gui=bold guibg=none guifg=none ctermbg=none ctermfg=none

      #     " Search highlighting
      #     hi Search term=bold,underline gui=bold,underline

      #     hi! def link VertSplit StatusLineNC

      #     hi! def link CocErrorSign ErrorMsg
      #     hi! def link CocErrorSign ErrorMsg
      #     highlight CocHighlightText gui=underline guibg=#282a2e cterm=underline ctermbg=10
      #     highlight CocHintHighlight cterm=none gui=none
      #     highlight CocInfoHighlight cterm=none gui=none
      #   '';
      # }
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
      # {
      #   plugin = nvim-dap;
      #   config = ''
      #     nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
      #     nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
      #     nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
      #     nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
      #     nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
      #     nnoremap <silent> <leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
      #     nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
      #     " nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
      #     " nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>
      #   '' + luaConfig ''
      #     local dap = require('dap')
      #     dap.adapters.cppdbg = {
      #       id = 'cppdbg',
      #       type = 'executable',
      #       command = '${
      #         (x: y: x) "" pkgs.vscode-extensions.ms-vscode.cpptools
      #       }/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7',
      #     }
      #     dap.configurations.cpp = {
      #       {
      #         name = "Launch file",
      #         type = "cppdbg",
      #         request = "launch",
      #         program = function()
      #           return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      #         end,
      #         cwd = ''\'''${workspaceFolder}',
      #         stopOnEntry = true,
      #       },
      #       {
      #         name = 'Attach to gdbserver :1234',
      #         type = 'cppdbg',
      #         request = 'launch',
      #         MIMode = 'gdb',
      #         miDebuggerServerAddress = 'localhost:1234',
      #         miDebuggerPath = '/usr/bin/gdb',
      #         cwd = ''\'''${workspaceFolder}',
      #         program = function()
      #           return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      #         end,
      #       },
      #     }
      #   '';
      # }
      # nvim-gdb
      # nvim-dap-ui
      {
        plugin = suda-vim;
        config = ''
          cmap w!! SudaWrite
        '';
      }
    ];
    initExtra = pkgs.substituteAll {
      src = ./init.vim;
      shortcut = config.programs.tmux.shortcut;
    };
  };
}
