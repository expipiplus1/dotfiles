{ config, pkgs, ... }:

{
  imports = [ ./home/zsh.nix ./home/git.nix ./home/tmux.nix ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  news.display = "silent";

  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    NIX_PATH = "nixpkgs=$HOME/src/nixpkgs:home-manager=$HOME/src/home-manager";
    EDITOR = "vim";
  };

  home.packages = with pkgs; [
    bmon
    coreutils
    curl
    file
    fzf
    fzy
    gist
    graphviz
    htop
    jq
    mosh
    silver-searcher
    tig
    tree
  ];
}
