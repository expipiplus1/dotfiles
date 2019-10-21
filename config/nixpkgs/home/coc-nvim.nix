{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [{
      plugin = coc-nvim.overrideAttrs (old: { src = /home/j/src/coc.nvim; });
      config = ''
        set runtimepath^=${
          builtins.getEnv "HOME"
        }/src/vscode-hie-server

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

        nmap <leader>e  <Plug>(coc-references)

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
      };
      #   hlintOn = true;
      #   maxNumberOfProblems = 100;
      #   diagnosticsOnChange = true;
      #   liquidOn = false;
      #   completionSnippetsOn = true;
      #   formatOnImportOn = true;
      #   formattingProvider = "brittany";
      #   hieExecutablePath = "hie-wrapper";
      #   useCustomHieWrapper = false;
      #   useCustomHieWrapperPath = "";
      #   showTypeForSelection.onHover = true;
      #   showTypeForSelection.command.location = "dropdown";
      #   trace.server = "verbose";
      #   enableHIE = true;
      # };
      languageserverJoe = {
        haskell = {
          # command = "/home/j/src/haskell-ide-engine2/dist-newstyle/build/x86_64-linux/ghc-8.6.5/haskell-ide-engine-1.0.0.0/x/hie/build/hie/hie";
          command = "hie-wrapper";
          args = [ "--vomit" "-l" ".hie-log" "-d" ];
          rootPatterns =
            [ ".stack.yaml" "cabal.config" "cabal.project" "package.yaml" ];
          requireRootPattern = true;
          filetypes = [ "hs" "lhs" "haskell" ];
          initializationOptions = { languageServerHaskell = { }; };
        };
      };
      languageserver = {
        # haskell = {
        #   # command = "/home/j/src/haskell-ide-engine2/dist-newstyle/build/x86_64-linux/ghc-8.6.5/haskell-ide-engine-1.0.0.0/x/hie/build/hie/hie";
        #   command = "hie-wrapper";
        #   args = [ "--vomit" "-l" ".hie-log" "-d" ];
        #   rootPatterns =
        #     [ ".stack.yaml" "cabal.config" "cabal.project" "package.yaml" ];
        #   requireRootPattern = true;
        #   filetypes = [ "hs" "lhs" "haskell" ];
        #   initializationOptions = { languageServerHaskell = { }; };
        # };

        # haskell = {
        #   command = "ghcide";
        # args = ["--lsp"];
        #   rootPatterns =
        #     [ ".stack.yaml" "cabal.config" "cabal.project" "package.yaml" ];
        #   requireRootPattern = true;
        #   filetypes = [ "hs" "lhs" "haskell" ];
        # };
      };
    };
  };
}
