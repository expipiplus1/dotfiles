{ config, pkgs, lib, ... }:

let

  pluginsWithConfig = with pkgs.vimPlugins; [
    open-browser-vim
    open-browser-github-vim
    {
      plugin = hlint-refactor-vim;
      config = ''
        let g:hlintRefactor#disableDefaultKeybindings = 1
        map <silent> <nowait> <leader>e :call ApplyOneSuggestion()<CR>
        map <silent> <nowait> <leader>E :call ApplyAllSuggestions()<CR>
      '';
    }
    {
      plugin = LanguageClient-neovim;
      config = ''
        let g:LanguageClient_serverCommands = {
          \ 'haskell': ['hie', '--lsp'],
          \ }

        map <Leader>ll :call LanguageClient_contextMenu()<CR>
        map <Leader>lk :call LanguageClient#textDocument_hover()<CR>
        map <Leader>lg :call LanguageClient#textDocument_definition()<CR>
        map <Leader>lr :call LanguageClient#textDocument_rename()<CR>
        map <Leader>lf :call LanguageClient#textDocument_rangeFormatting()<CR>
        map <Leader>ld :call LanguageClient#textDocument_formatting()<CR>
        map <Leader>lb :call LanguageClient#textDocument_references()<CR>
        map <Leader>la :call LanguageClient#textDocument_codeAction()<CR>
        map <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>
        map <Leader>lh :call LanguageClient#textDocument_documentHighlight()<CR>
        map <Leader>le :call LanguageClient#workspace_applyEdit()<CR>
        nnoremap <nowait> <leader>R :call LanguageClient#textDocument_rename()<CR>

        " Rename - rn => rename
        noremap <leader>rn :call LanguageClient#textDocument_rename()<CR>

        " Rename - rc => rename camelCase
        noremap <leader>rc :call LanguageClient#textDocument_rename(
                    \ {'newName': Abolish.camelcase(expand('<cword>'))})<CR>

        " Rename - rs => rename snake_case
        noremap <leader>rs :call LanguageClient#textDocument_rename(
                    \ {'newName': Abolish.snakecase(expand('<cword>'))})<CR>

        " Rename - ru => rename UPPERCASE
        noremap <leader>ru :call LanguageClient#textDocument_rename(
                    \ {'newName': Abolish.uppercase(expand('<cword>'))})<CR>
      '';
    }
  ];

  # TODO: Reduce duplication with neovim.nix
  pluginConfig = p:
    if builtins.hasAttr "plugin" p && builtins.hasAttr "config" p then ''
      """"""""""""""""""""""""""""""""
      " ${p.plugin.pname}
      """"""""""""""""""""""""""""""""
      ${p.config}
    '' else
      "";

in
{
  imports = [
    ./tex.nix
    ./haskell.nix
  ];

  home.packages = with pkgs; [
    ffmpeg
    powerline-fonts
  ];

  programs.neovim = {
    extraConfig = lib.concatMapStrings pluginConfig pluginsWithConfig;
  };
}
