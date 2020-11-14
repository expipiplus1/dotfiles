{ pkgs, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = coc-nvim.overrideAttrs (_: {
          src = import (pkgs.fetchgit {
            url = "https://github.com/expipiplus1/coc.nvim";
            rev = "0b7929395ac539a87dfbb89db7b3d9db90d99556"; # joe-links
            sha256 = "1kvwp1mh511dk1ic7c82ipq0ih27ycz95zysmnl3sadqnxw9s9d0";
            leaveDotGit = true;
          }) { inherit pkgs; };
        });
        config = ''
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " Highlight current word
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " Highlight symbol under cursor on CursorHold
          autocmd CursorHold * silent call CocActionAsync('highlight')
          highlight CocHighlightText gui=underline guibg=#282a2e cterm=underline ctermbg=10
          " TODO, this doesn't belong here
          set updatetime=100

          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " Browse documentation
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          function! s:show_documentation()
            if (index(['vim','help'], &filetype) >= 0)
              execute 'h '.expand('<cword>')
            else
              call CocAction('doHover')
            endif
          endfunction

          " Use K to show documentation in preview window
          nnoremap <silent> K :call <SID>show_documentation()<CR>

          " Open the documentation window, search for a link and follow it in the
          " browser
          function! s:open_documentation_link(target)
            call s:show_documentation()
            let float_window = coc#float#get_float_win()
            if !float_window
              echo "No documentation available"
              return
            endif
            if !win_gotoid(float_window)
              echo "Unable to go to documentation window"
              return
            endif
            if !search("\\[" . a:target . "](", "ce")
              echo "No documenation link found"
            else
              exe "normal gx"
            endif
            call coc#float#close_all()
          endfunction

          nnoremap <silent> <leader>l :call <SID>open_documentation_link("Source")<CR>
          nnoremap <silent> <leader>k :call <SID>open_documentation_link("Documentation")<CR>

          "
          " Coc navigation
          "
          " Remap keys for gotos
          nmap <silent> gd <Plug>(coc-definition)
          nmap <silent> gy <Plug>(coc-type-definition)
          nmap <silent> gi <Plug>(coc-implementation)
          nmap <silent> gr <Plug>(coc-references)

          nmap <leader>e  <Plug>(coc-references)

          nmap <silent> <leader>[ <Plug>(coc-diagnostic-prev)
          nmap <silent> <leader>] <Plug>(coc-diagnostic-next)

          "
          " Coc visuals
          "

          " Remap for format selected region
          xmap <leader>f  <Plug>(coc-format-selected)
          nmap <leader>f  <Plug>(coc-format-selected)
          nmap <leader>F  <Plug>(coc-format)

          "
          " Coc modification
          "
          " Fix autofix problem of current line
          nmap <leader>ca  <Plug>(coc-codeaction)
          " Fix autofix problem of current line
          nmap <leader>qf  <Plug>(coc-fix-current)
          nmap <leader>ql  <Plug>(coc-codelens-action)
          nmap <leader>re  <Plug>(coc-rename)

          "
          " Coc completion
          "

          " use <tab> for trigger completion and navigate to the next complete item
          function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~ '\s'
          endfunction

          inoremap <silent><expr> <Tab>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<Tab>" :
                \ coc#refresh()

          inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
          inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
        '';
      }
      {
        plugin = coc-fzf;
        config = ''
          nnoremap <silent> <leader>ca :CocFzfList actions<CR>
          nnoremap <silent> <leader>i  :CocFzfList<CR>
          nnoremap <silent> <leader>d  :CocFzfList diagnostics<CR>
          nnoremap <silent> <leader>o  :CocFzfList outline<CR>
        '';
      }
      (pkgs.vimUtils.buildVimPluginFrom2Nix {
        name = "vscode-haskell";
        src = import (pkgs.fetchFromGitHub {
          owner = "expipiplus1";
          repo = "vscode-hie-server";
          rev = "ff20690c99595aaa920047855104336357b062ed";
          sha256 = "12zwrvw6nw76qlpc7xjlg70f1fmi0gfamflng0n5srsbgqdi02wz";
        }) { inherit pkgs; };
      })
      (coc-diagnostic.overrideAttrs (_old: {
        src = import (pkgs.fetchFromGitHub {
          owner = "expipiplus1";
          repo = "coc-diagnostic";
          rev = "ffbd066a3c4dcfec72106dc7150c7a35a6b415dd";
          sha256 = "1gl4dxphwyxx3d0pw02ivwxa5d6npc9bl2yrbfmw3s0c0rflhspi";
        }) { inherit pkgs; };
      }))
      { plugin = coc-rls; }
    ];
    withNodeJs = true;
  };

  xdg.configFile."nvim/coc-settings.json".source = pkgs.writeTextFile {
    name = "coc-settings.json";
    text = builtins.toJSON {
      diagnostic = {
        virtualText = true;
        checkCurrentLine = true;
        virtualTextCurrentLineOnly = false;
        virtualTextPrefix = "▷ ";
        errorSign = ">";
        warningSign = ">";
        infoSign = ">";
        hintSign = ">";
      };
      codeLens.enable = true;
      coc.preferences.rootPatterns = [ "default.nix" ];

      haskell = {
        logFile = "/tmp/hls.log";
        formattingProvider = "brittany";
        serverExecutablePath = pkgs.writeShellScript "nix-shell-hie" ''
          if [[ -f default.nix || -f shell.nix ]]; then
            ${pkgs.cached-nix-shell}/bin/cached-nix-shell --keep XDG_DATA_DIRS --arg hoogle true --run "${pkgs.haskell-language-server}/bin/haskell-language-server $(printf "''${1+ %q}" "$@")"
          else
            exec ${pkgs.haskell-language-server}/bin/haskell-language-server "$@"
          fi
        '';
      };

      diagnostic-languageserver = {
        linters = {
          shellcheck.command = "${pkgs.shellcheck}/bin/shellcheck";
          nix-linter = {
            command = pkgs.writeShellScript "nix-linter-json-list" ''
              echo '['
              cat | ${pkgs.nix-linter}/bin/nix-linter --json-stream - | sed '$!s/$/,/'
              echo ']'
            '';
            sourceName = "nix-linter";
            debounce = 100;
            parseJson = {
              line = "pos.spanBegin.sourceLine";
              column = "pos.spanBegin.sourceColumn";
              endLine = "pos.spanEnd.sourceLine";
              endColumn = "pos.spanEnd.sourceColumn";
              message = "\${description}";
            };
          };
          yamllint = {
            command = "${pkgs.yamllint}/bin/yamllint";
            args = [ "-f" "parsable" "-" ];
            sourceName = "yamllint";
            debounce = 100;
            formatLines = 1;
            formatPattern = [
              "^.*?:(\\d+):(\\d+): \\[(.*?)] (.*) \\((.*)\\)"
              {
                line = 1;
                column = 2;
                endline = 1;
                endColumn = 2;
                message = 4;
                security = 3;
                code = 5;
              }
            ];
            securities = {
              error = "error";
              warning = "warning";
            };
          };
        };
        formatters = {
          nixfmt.command = "${pkgs.nixfmt}/bin/nixfmt";
          shfmt = {
            command = "${pkgs.shfmt}/bin/shfmt";
            args = [ "-i" "2" ];
          };
          ymlfmt.command = "${pkgs.ymlfmt}/bin/ymlfmt";
        };
        formatFiletypes = {
          nix = "nixfmt";
          sh = "shfmt";
          yaml = "ymlfmt";
        };
        filetypes = {
          nix = "nix-linter";
          yaml = "yamllint";
          sh = "shellcheck";
        };
      };
      languageserver = {
        clangd = {
          command = "${pkgs.clang-tools}/bin/clangd";
          args = [ "--background-index" "--compile-commands-dir=build" ];
          rootPatterns = [
            "compile_flags.txt"
            "compile_commands.json"
            ".git"
            "CMakeLists.txt"
          ];
          filetypes = [ "c" "cpp" "objc" "objcpp" ];
        };
      };
    };
  };
}
