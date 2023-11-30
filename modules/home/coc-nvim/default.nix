{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "coc-nvim" {
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
            let float_windows = coc#float#get_float_win_list()
            if empty(float_windows)
              echo "No documentation available"
              return
            endif
            if !win_gotoid(float_windows[0])
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
          nmap <silent> <leader>j <Plug>(coc-diagnostic-info)

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

          inoremap <silent><expr> <TAB>
            \ coc#pum#visible() ? coc#pum#next(1):
            \ <SID>check_back_space() ? "\<Tab>" :
            \ coc#refresh()


          inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

          inoremap <expr><C-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
          inoremap <expr><C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"

          " Use enter to accept completion and insert snippets (usually imports)
          inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

          " hi CocSearch ctermfg=12 guifg=#18A3FF
          " hi CocMenuSel ctermbg=109 guibg=#13354A
          hi! def link CocSearch SpecialChar
          hi! def link CocMenuSel Visual
        '';
      }
      {
        plugin = coc-fzf.overrideAttrs (_: {
          src = pkgs.fetchFromGitHub {
            owner = "antoinemadec";
            repo = "coc-fzf";
            rev = "5fae5a15497750483e21fc207aa6005f340f02f2"; # master
            sha256 = "1r9jhdxm3y1lpdmwmlk48skihf7jxdm2sxirzyd1kwb88nvn4c3r";
          };
        });
        config = ''
          nnoremap <silent> <leader>ca :CocFzfList actions<CR>
          vnoremap <silent> <leader>ca :CocFzfList actions<CR>
          nnoremap <silent> <leader>i  :CocFzfList<CR>
          nnoremap <silent> <leader>d  :CocFzfList diagnostics --current-buf<CR>
          nnoremap <silent> <leader>D  :CocFzfList diagnostics<CR>
          nnoremap <silent> <leader>o  :CocFzfList outline<CR>
          nnoremap <silent> <leader>m  :CocFzfList symbols<CR>
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
      coc-diagnostic
      coc-rust-analyzer
      {
        plugin = coc-clangd;
        config = ''
          nmap <silent> gh :CocCommand clangd.switchSourceHeader<CR>
        '';
      }
      # coc-nil
    ];
    withNodeJs = true;
  };

  home.packages = with pkgs; [ cmake-format ];

  xdg.configFile."nvim/coc-settings.json".source = pkgs.writeTextFile {
    name = "coc-settings.json";
    text = builtins.toJSON {

      diagnostic = {
        enableMessage = "jump";
        virtualText = true;
        checkCurrentLine = true;
        virtualTextPrefix = "▷ ";
        errorSign = ">";
        warningSign = ">";
        infoSign = ">";
        hintSign = ">";
      };
      hover.autoHide = true;
      codeLens.enable = true;
      codeLens.position = "eol";
      coc.preferences.rootPatterns =
        [ "flake.nix" "default.nix" "shell.nix" "cabal.project" "hie.yaml" ];
      suggest.noselect = true;
      "[c][cpp]".inlayHint.enable = false;

      languageserver = {
        haskell = {
          command = "haskell-language-server-wrapper";
          args = [ "--lsp" ];
          filetypes = [ "hs" "lhs" "haskell" ];
          rootPatterns = [
            ".stack.yaml"
            ".hie-bios"
            "cabal.config"
            "package.yaml"
            "cabal.project"
            "hie.yaml"
          ];
          settings.haskell = {
            formattingProvider = "fourmolu";
            formatOnImportOn = false;
            plugin.ghcide-completions.config.snippetsOn = true;
            plugin.ghcide-completions.config.autoExtendOn = true;
            plugin.rename.config.crossModule = true;
            plugin.fourmolu.config.external = true;
          };
        };

        cmake = {
          command = "${pkgs.cmake-language-server}/bin/cmake-language-server";
          filetypes = [ "cmake" ];
          rootPatterns = [ "build/" ];
          initializationOptions = {
            buildDirectory = "build-cmake";
            formatProgram = "${pkgs.gersemi}/bin/gersemi";
            formatArgs = [ "--definitions" "cmake" "--" "-" ];
          };
        };

        nix = {
          command = "${pkgs.nil}/bin/nil";
          filetypes = [ "nix" ];
          rootPatterns = [ "flake.nix" ];
          # Uncomment these to tweak settings.
          settings.nil = {
            formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
          };
        };
      };

      rust-analyzer.server.path = "rust-analyzer";

      clangd = {
        path = "${pkgs.clang-tools_16}/bin/clangd";
        arguments = [
          "--background-index"
          "--all-scopes-completion"
          "--clang-tidy"
          "--suggest-missing-includes"
        ];
      };

      diagnostic-languageserver = {
        mergeConfig = true;
        linters = {
          shellcheck = { command = "${pkgs.shellcheck}/bin/shellcheck"; };
          # nix-linter = {
          #   command = pkgs.writeShellScript "nix-linter-json-list" ''
          #     echo '['
          #     cat | ${pkgs.nix-linter}/bin/nix-linter --json-stream - | sed '$!s/$/,/'
          #     echo ']'
          #   '';
          #   sourceName = "nix-linter";
          #   debounce = 100;
          #   parseJson = {
          #     line = "pos.spanBegin.sourceLine";
          #     column = "pos.spanBegin.sourceColumn";
          #     endLine = "pos.spanEnd.sourceLine";
          #     endColumn = "pos.spanEnd.sourceColumn";
          #     message = "\${description}";
          #   };
          # };
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
          shfmt = {
            command = "${pkgs.shfmt}/bin/shfmt";
            args = [ "-i" "2" ];
          };
          ymlfmt.command = "${pkgs.ymlfmt}/bin/ymlfmt";
        };
        formatFiletypes = {
          sh = "shfmt";
          yaml = "ymlfmt";
        };
        filetypes = {
          yaml = "yamllint";
          sh = "shellcheck";
        };
      };
    };
  };
}
