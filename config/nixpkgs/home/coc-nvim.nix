{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ coc-nvim ];
    withNodeJs = true;
    extraConfig = ''
      function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
          execute 'h '.expand('<cword>')
        else
          call CocAction('doHover')
        endif
      endfunction

      " Use K to show documentation in preview window
      nnoremap <silent> K :call <SID>show_documentation()<CR>

      "
      " Coc navigation
      "
      " Remap keys for gotos
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)

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
    '';
  };

  xdg.configFile."nvim/coc-settings.json".source = pkgs.writeTextFile {
    name = "coc-settings.json";
    text = builtins.toJSON {
      languageserver = {
        haskell = {
          command = "hie-wrapper";
          rootPatterns =
            [ ".stack.yaml" "cabal.config" "cabal.project" "package.yaml" ];
          requireRootPattern = true;
          filetypes = [ "hs" "lhs" "haskell" ];
          initializationOptions = {
            languageServerHaskell = { hlintOn = true; };
          };
        };
      };
    };
  };
}
