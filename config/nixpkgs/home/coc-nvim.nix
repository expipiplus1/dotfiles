{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = coc-nvim.overrideAttrs (old: {
          src = import (pkgs.fetchgit {
            url = "https://github.com/expipiplus1/coc.nvim";
            rev = "12400280fb132578b2ed7cf4135873893639282d";
            sha256 = "1arwg5ybf2f3hsy8y7kgnck0pmqalpjkyckj9wyc3l32wj5n33l1";
            leaveDotGit = true;
          }) { inherit pkgs; };
        });
        config = ''
          set runtimepath^=${
            import (pkgs.fetchFromGitHub {
              owner = "alanz";
              repo = "vscode-hie-server";
              rev = "79ce9166ad7e4eb67153a5ba5a552243b85b7d4f";
              sha256 = "0w4cgprfyr12mgrkd172l27fx10vnb47kwv0r7x3i969ih6p05s7";
            }) { inherit pkgs; }
          }

          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " Highlight current word
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " set runtimepath^=${
            pkgs.fetchFromGitHub {
              owner = "neoclide";
              repo = "coc-highlight";
              rev = "b4e82ebd5fe855d004dd481e2ecf2fa88faed284";
              sha256 = "06h64jq8cgj5hc19inidns046kkb76750179jsw7xv5zbp93ygap";
            }
          }
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
            let float_window = coc#util#get_float()
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
            call coc#util#float_hide()
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

          "
          " Coc modification
          "
          " Fix autofix problem of current line
          nmap <leader>ca  <Plug>(coc-codeaction)
          " Fix autofix problem of current line
          nmap <leader>qf  <Plug>(coc-fix-current)


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
          nnoremap <silent> <leader>i :CocFzfList<CR>
          nnoremap <silent> <leader>d :CocFzfList diagnostics<CR>
        '';
      }
    ];
    withNodeJs = true;
  };

  xdg.configFile."nvim/coc-settings.json".source = pkgs.writeTextFile {
    name = "coc-settings.json";
    text = builtins.toJSON {
      coc.preferences.diagnostic = {
        virtualText = true;
        virtualTextPrefix = "▷ ";
        errorSign = ">";
        warningSign = ">";
        infoSign = ">";
        hintSign = ">";
      };
      coc.preferences.codeLens.enable = true;
      coc.preferences.rootPatterns = [ "default.nix" ];
      languageServerHaskell = {
        trace.server = "verbose";
        hieExecutablePath = pkgs.writeShellScript "nix-shell-hie" ''
          if [[ -f default.nix || -f shell.nix ]]; then
            ${pkgs.cached-nix-shell}/bin/cached-nix-shell --keep XDG_DATA_DIRS --arg hoogle true --run "hie -l /tmp/hie.log $(printf "''${1+ %q}" "$@")"
          else
            exec hie "$@"
          fi
        '';
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
