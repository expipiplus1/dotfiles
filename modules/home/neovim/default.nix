{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "neovim" (let
  appendPatches = patches: drv:
    drv.overrideAttrs (old: { patches = old.patches or [ ] ++ patches; });

  luaConfig = lua: ''
    lua <<EOF
    ${lua}
    EOF
  '';

  mergeBefore = x: xs: lib.mkMerge [ (lib.mkBefore [ x ]) xs ];

  codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.overrideAttrs
    (finalAttrs: previousAttrs: { lldb = pkgs.lldb_16; });
  codelldb_path =
    "${codelldb}/share/vscode/extensions/${codelldb.vscodeExtPublisher}.${codelldb.vscodeExtName}";

  vscode_cpptools = pkgs.vscode-extensions.ms-vscode.cpptools;
  vscode_cpptools_path =
    "${vscode_cpptools}/share/vscode/extensions/${vscode_cpptools.vscodeExtPublisher}.${vscode_cpptools.vscodeExtName}";

  vimspector_configuration = {
    adapters = {
      CodeLLDB = {
        command = [
          "${codelldb_path}/adapter/codelldb"
          "--port"
          "\${unusedLocalPort}"
        ];
        configuration = {
          args = [ ];
          cargo = { };
          cwd = "\${workspaceRoot}";
          env = { };
          name = "lldb";
          terminal = "integrated";
          type = "lldb";
        };
        name = "CodeLLDB";
        port = "\${unusedLocalPort}";
        type = "CodeLLDB";
      };
      multi-session = {
        host = "\${host}";
        port = "\${port}";
      };
      vscode-cpptools = {
        attach = {
          pidProperty = "processId";
          pidSelect = "ask";
        };
        command = [ "${vscode_cpptools_path}/debugAdapters/bin/OpenDebugAD7" ];
        configuration = {
          args = [ ];
          cwd = "\${workspaceRoot}";
          environment = [ ];
          type = "cppdbg";
        };
        name = "cppdbg";
      };
    };
  };

in {
  home.file = {
    ".config/vimspector/gadgets/linux/.gadgets.json".source =
      pkgs.writeText ".gadgets.json" (builtins.toJSON vimspector_configuration);
  };
  home.packages = [ pkgs.bc ];
  ellie.treesitter.enable = true;
  ellie.coc-nvim.enable = true;
  programs.neovim = with pkgs.vimPlugins; {
    enable = true;
    # package = appendPatches [ ./nvim-backup-dir.patch ./nvim-backup-perms.patch ] pkgs.neovim-unwrapped;
    vimAlias = true;
    plugins = mergeBefore {
      plugin = pkgs.hello; # dummy package
      config = ''
        " initExtra
        source ${
          pkgs.substituteAll {
            src = ./init.vim;
            shortcut = config.programs.tmux.shortcut;
          }
        }
      '';
    } [
      {
        plugin = vimspector;
        config = ''
          let g:vimspector_enable_mappings = 'HUMAN'
          let g:vimspector_base_dir=expand( '$HOME/.config/vimspector' )
        '';
      }

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
      # tmux-complete-vim
      (appendPatches [ ./plug-patches/cabal-module-word.patch ] haskell-vim)
      vim-strip-trailing-whitespace
      {
        plugin = treesj;
        type = "lua";
        config = ''
          require('treesj').setup({
            use_default_keymaps = false,

            -- Node with syntax error will not be formatted
            check_syntax_error = false,

            -- If line after join will be longer than max value,
            -- node will not be formatted
            max_join_length = 999,
          })
          -- p for parameter
          vim.keymap.set('n', '<leader>p', require('treesj').toggle)
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
          name = "fcitx5-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "pysan3";
            repo = "fcitx5.nvim";
            rev = "e2154f63e01baa2e7e3d1ce3810bf82b17986720";
            sha256 = "0n0l2wb60scg310djg1i70grpz3kv557j79n54wd5g56bf8dliq1";
          };
        });
        config = luaConfig ''
          local en = "keyboard-us"
          local ja = "mozc"

          require("fcitx5").setup({
            imname = {
              norm = en,
              ins = en,
              cmd = en,
            },
            remember_prior = true,
            define_autocmd = true,
          })
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
      vim-abolish
      vim-easy-align
      vim-fugitive
      # {
      #   plugin = vim-gitgutter;
      #   config = ''
      #     let g:gitgutter_sign_added                   = '▎'
      #     let g:gitgutter_sign_modified                = '▎'
      #     let g:gitgutter_sign_removed                 = '▁'
      #     let g:gitgutter_sign_removed_first_line      = '▔'
      #     let g:gitgutter_sign_removed_above_and_below = '🮀'
      #     let g:gitgutter_sign_modified_removed        = '▎'
      #     nmap <silent> yog :GitGutterToggle<CR>
      #   '';
      # }
      vim-gist
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
      {
        plugin = vim-tmux-navigator;
        config = ''
          if exists('g:vscode')
            let g:tmux_navigator_no_mappings = 1
            nmap <silent> <c-h> <C-W>h
            nmap <silent> <c-j> <C-W>j
            nmap <silent> <c-k> <C-W>k
            nmap <silent> <c-l> <C-W>l
            nmap <silent> <c-\> <C-W>\
          endif
        '';
      }
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

          ""
          " Less bold/italic
          " To discover these, use: TSPlaygroundToggle and in that buffer press
          " 'i' to show the highlight groups
          "
          " Big list here:
          " https://github.com/shaunsingh/nord.nvim/blob/fab04b2dd4b64f4b1763b9250a8824d0b5194b8f/lua/nord/theme.lua#L315-L369
          ""
          hi @conditional gui=NONE
          hi @repeat gui=NONE
          hi @keyword gui=NONE
          hi @keyword.operator gui=NONE
          hi @keyword.return gui=NONE
          hi @keyword.function gui=NONE
          hi @function.builtin gui=NONE
          hi @boolean gui=NONE

          hi @function gui=NONE
          hi @variable gui=NONE
          hi @method gui=NONE
          hi @field gui=NONE
          hi @property gui=NONE
          hi @namespace gui=NONE
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
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          require("which-key").setup {
          }
        '';
      }
      {
        plugin = suda-vim;
        config = ''
          command! WW SudaWrite
        '';
      }
      vim-spirv
    ];
  };
})
