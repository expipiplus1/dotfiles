{ config, pkgs, ... }:

{
  imports = [
    ./home/zsh.nix
    ./home/git.nix
    ./home/tmux.nix
    ./home/neovim.nix
    ./home/tex.nix
    ./home/haskell.nix
  ];

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
    ffmpeg
    file
    fzf
    fzy
    gist
    graphviz
    htop
    jq
    mosh
    nix
    pandoc
    pdftk
    silver-searcher
    tig
    tree
    cachix
    upfind
    update-nix-fetchgit
  ];
}
