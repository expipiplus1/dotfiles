{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [{
      plugin = coc-nvim;
      config = ''
        set runtimepath^=${
          import "${builtins.getEnv "HOME"}/src/vscode-hie-server" {
            inherit pkgs;
          }
        }

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

        nnoremap <silent> <leader>i :CocList<CR>

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
        " Highlight symbol under cursor on CursorHold
        autocmd CursorHold * silent call CocActionAsync('highlight')

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
    }];
    withNodeJs = true;
  };

  xdg.configFile."nvim/coc-settings.json".source = pkgs.writeTextFile {
    name = "coc-settings.json";
    text = builtins.toJSON {
      languageServerHaskell = {
        trace.server = "verbose";
        hieExecutablePath = pkgs.writeShellScript "nix-shell-hie" ''
          if [[ -f default.nix || -f shell.nix ]]; then
            ${pkgs.cached-nix-shell}/bin/cached-nix-shell --run "hie $(printf "''${1+ %q}" "$@")"
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
