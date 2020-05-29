{ config, pkgs, lib, ... }:

let


in
{
  imports = [
    ./tex.nix
    ./haskell.nix
    ./coc-nvim.nix
    ./alacritty.nix
  ];

  home.packages = with pkgs; [
    ffmpeg
    powerline-fonts
    xsel
    vscode
    signal-desktop
    firefox
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      open-browser-vim
      open-browser-github-vim
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
