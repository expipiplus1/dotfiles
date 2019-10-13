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
    nixfmt
    nix-prefetch-github
    nix-prefetch-git
    pandoc
    pdftk
    silver-searcher
    tig
    tree
    cachix
    upfind
    update-nix-fetchgit
    powerline-fonts
  ];

  xdg.configFile."nixpkgs/config.nix".source = pkgs.writeTextFile {
    name = "config.nix";
    text = ''
      (import <home-manager/modules> {
        pkgs = import <nixpkgs> {config={}; overlays=[];};
          configuration = import (builtins.getEnv "HOME" + "/.config/nixpkgs/home.nix");
        }).config.nixpkgs.config
    '';
  };
  xdg.configFile."nixpkgs/overlays.nix".source = pkgs.writeTextFile {
    name = "overlays.nix";
    text = ''
      (import <home-manager/modules> {
        pkgs = import <nixpkgs> {config={}; overlays=[];};
          configuration = import (builtins.getEnv "HOME" + "/.config/nixpkgs/home.nix");
        }).config.nixpkgs.overlays
    '';
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    android_sdk.accept_license = true;
  };

  nixpkgs.overlays = [
  ];
}
