{ config, pkgs, lib, ... }:

let


in
{
  imports = [
    ./tex.nix
    ./haskell.nix
    ./coc-nvim.nix
  ];

  home.packages = with pkgs; [
    ffmpeg
    powerline-fonts
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
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
    ];
  };

  programs.tmux = {
    plugins = [ pkgs.tmuxPlugins.open ];
  };

  programs.zsh = {
    initExtraBeforeCompInit = ''
      wd() {
        nix-store -q --graph "$1" |
          ${pkgs.graphviz}/bin/dijkstra -da "$2" |
          ${pkgs.graphviz}/bin/gvpr -c 'N[dist>1000.0]{delete(NULL, $)}' |
          ${pkgs.graphviz}/bin/dot -Tsvg |
          ${pkgs.imagemagick}/bin/display
      }
    '';
  };
}
