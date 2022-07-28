{ pkgs, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = coc-nvim;
        # plugin = coc-nvim.overrideAttrs (_: {
        #   # src = import (pkgs.fetchgit {
        #   #   url = "https://github.com/expipiplus1/coc.nvim";
        #   #   rev = "8baff05b4c7bb770cda0a088670a069d8eb8c1b4"; # joe
        #   #   sha256 = "1wwbdc1qbqk0xsyfmyd48hbxjv9z3ajm8vm2jxl4ah55jf3wb2la";
        #   #   leaveDotGit = true;
        #   # }) { inherit pkgs; };
        #   src = import /home/j/src/coc.nvim { inherit pkgs; };
        # });
        config = ''
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " Highlight current word
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " Highlight symbol under cursor on CursorHold
          autocmd CursorHold * silent call CocActionAsync('highlight')
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
            if !search(a:target . ": .", "bcew")
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
          nmap <leader>ca  <Plug>(coc-codeaction-cursor)
          vmap <leader>ca  <Plug>(coc-codeaction)
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

          inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

          " Use enter to accept completion and insert snippets (usually imports)
          inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
        '';
      }
      {
        plugin = coc-fzf.overrideAttrs (_: {
          src = pkgs.fetchFromGitHub {
            owner = "antoinemadec";
            repo = "coc-fzf";
            rev = "60828294b9ba846c78893389d4772021043d2fa1"; # master
            sha256 = "1y7rslksa558fdh3m4m626vpvs424pvxkkk70mr57is47cminm3m";
          };
        });
        config = ''
          nnoremap <silent> <leader>ca :CocFzfList actions<CR>
          vnoremap <silent> <leader>ca :CocFzfList actions<CR>
          nnoremap <silent> <leader>i  :CocFzfList<CR>
          nnoremap <silent> <leader>d  :CocFzfList diagnostics<CR>
          nnoremap <silent> <leader>o  :CocFzfList outline<CR>
        '';
      }
      {
        plugin = coc-snippets;
        config = ''
          " Use <C-j> for both expand and jump (make expand higher priority.)
          imap <expr><C-j> coc#_select_confirm()
          imap <expr><C-b> coc#_select_confirm()

          " Use <C-j> for jump to next placeholder, it's default of coc.nvim
          let g:coc_snippet_next = '<c-j>'

          " Use <C-k> for jump to previous placeholder, it's default of coc.nvim
          let g:coc_snippet_prev = '<c-k>'
        '';
      }
      (pkgs.vimUtils.buildVimPluginFrom2Nix {
        name = "vscode-haskell";
        src = import (pkgs.fetchFromGitHub {
          owner = "expipiplus1";
          repo = "vscode-hie-server";
          rev = "b7ed3d80262bed55b37fafc7d3d8de8bbcf76564"; # coc.nvim
          sha256 = "0lbjc5dr33n6fcbmr70ppkijj2wbnkdriww219sczjyx84pvajgs";
        }) { inherit pkgs; };
      })
      (coc-diagnostic.overrideAttrs (_old: {
        src = import (pkgs.fetchFromGitHub {
          owner = "expipiplus1";
          repo = "coc-diagnostic";
          rev = "30db849e41b07962cc150f9f50e63655a82d0316"; # nix
          sha256 = "0nmhhkibj1fh972r578fkrmkcvm122rk9lfnbxsxmqm9hxld59x6";
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
      codeLens.position = "eol";
      coc.preferences.rootPatterns =
        [ "default.nix" "shell.nix" "cabal.project" "hie.yaml" ];

      # languageserver.haskell = {
      #   command = "haskell-language-server-wrapper";
      #   args = [ "--lsp" ];
      #   filetypes = [ "hs" "lhs" "haskell" ];
      #   rootPatterns =
      #     [ ".stack.yaml" ".hie-bios" "cabal.config" "package.yaml" ];
      # };
      haskell = {
        logFile = "/tmp/hls.log";
        formattingProvider = "brittany";
        formatOnImportOn = true;
        plugin.ghcide-completions.config.snippetsOn = true;
        plugin.ghcide-completions.config.autoExtendOn = true;
        # serverExecutablePath = pkgs.writeShellScript "nix-shell-hie" ''
        #   if [[ -f default.nix || -f shell.nix ]]; then
        #     ${pkgs.cached-nix-shell}/bin/cached-nix-shell --keep XDG_DATA_DIRS --arg hoogle true --run "${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper --debug $(printf "''${1+ %q}" "$@")"
        #   else
        #     exec ${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper "$@"
        #   fi
        # '';
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
      languageserver.clangd = {
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
}
