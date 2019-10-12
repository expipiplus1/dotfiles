{ config, pkgs, ... }:

{
  imports = [
    ./home/zsh.nix
    ./home/git.nix
    ./home/tmux.nix
    ./home/neovim.nix
    ./home/tex.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  news.display = "silent";

  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    NIX_PATH = "nixpkgs=$HOME/src/nixpkgs:home-manager=$HOME/src/home-manager";
    EDITOR = "vim";
  };

  home.packages = with pkgs;
    [
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
      pandoc
      pdftk
      silver-searcher
      tig
      tree
    ] ++ (with haskellPackages; [
      apply-refact
      ghcid
      hindent
      hlint
      pretty-show
      stylish-haskell
      cabal2nix
      brittany
      upfind
      nix-diff
      hpack
    ]);

  nixpkgs.overlays = [
    (import ((builtins.fetchTarball {
      url =
        "https://github.com/dhess/dhess-lib-nix/archive/b351d482784b11829d1d31979ecd11d437038fc3.tar.gz";
      sha256 = "0b1v4jlbm1z11q9zq6h40sh72cwc0c194zk88bpdm8j4ill98hc3";
    }) + "/overlays/haskell/lib.nix"))
    (self: super: {
      haskellPackages = super.haskell.lib.properExtend super.haskellPackages
        (self: super: {
          upfind = import (pkgs.fetchFromGitHub {
            owner = "expipiplus1";
            repo = "upfind";
            rev = "cb451254f5b112f839aa36e5b6fd83b60cf9b9ae";
            sha256 = "15g5nvs6azgb2fkdna1dxbyiabx9n63if0wcbdvs91hjafhzjaqa";
          } ) {};
        });
    })
  ];
}
