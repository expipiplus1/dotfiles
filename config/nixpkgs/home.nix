{ config, pkgs, lib, ... }:

{
  imports = [
    ./home/zsh.nix
    ./home/git.nix
    ./home/tmux.nix
    ./home/neovim.nix
    ./home/pc.nix
  ] ++ lib.optional (builtins.getEnv "BANKID" != "") ./home/scb.nix;

  home.username = "j";

  # Let Home Manager install and manage itself.
  programs.home-manager = {
    enable = true;
    path = builtins.getEnv "HOME" + "/src/home-manager";
  };
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
    htop
    jq
    mosh
    nix
    nix-prefetch-git
    nix-prefetch-github
    silver-searcher
    tree
    tssh
    cached-nix-shell
  ];

  xdg.configFile = let
    autostart = c: {
      "autostart/${c}.desktop".source = pkgs.writeTextFile {
        name = "a.desktop";
        text = ''
          [Desktop Entry]
          Type=Application
          Exec=sh -c 'sleep 1 && ${c}'
          Hidden=false
          X-GNOME-Autostart-enabled=true
          Name=${c}
                   '';
      };
    };
  in {
    "nixpkgs/config.nix".source = pkgs.writeTextFile {
      name = "config.nix";
      text = ''
        (import ${config.programs.home-manager.path}/modules {
          pkgs = import <nixpkgs> {config={}; overlays=[];};
            configuration = import (builtins.getEnv "HOME" + "/.config/nixpkgs/home.nix");
          }).config.nixpkgs.config
      '';
    };
    "nixpkgs/overlays.nix".source = pkgs.writeTextFile {
      name = "overlays.nix";
      text = ''
        (import ${config.programs.home-manager.path}/modules {
          pkgs = import <nixpkgs> {config={}; overlays=[];};
            configuration = import (builtins.getEnv "HOME" + "/.config/nixpkgs/home.nix");
          }).config.nixpkgs.overlays
      '';
    };
  } // autostart "firefox"
  // autostart "alacritty --command zsh -i -c 'tmux attach'";

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    android_sdk.accept_license = true;
  };

  nixpkgs.overlays = [
    (self: super: {
      tssh = self.writeTextFile {
        name = "tssh";
        text = ''
          #/usr/bin/env sh
          ${pkgs.mosh}/bin/mosh --server=.nix-profile/bin/mosh-server "$@" -- .nix-profile/bin/tmux attach
        '';
        executable = true;
        destination = "/bin/tssh";
      };
      cached-nix-shell = self.rustPlatform.buildRustPackage rec {
        name = "cached-nix-shell";

        src = self.fetchFromGitHub {
          owner = "xzfc";
          repo = "cached-nix-shell";
          rev = "264d34405eecdcfa670d0a0451ee92877b615e3a";
          sha256 = "1gkdwbn252790cadfiniv41v131mrgkfq3k3myj98rs19hazbrxf";
        };

        cargoSha256 = "1rzhahbp5fwwpafa04xs4zfajcpf3bm73v691d13kgjg56p0iwyf";

        CNS_IN_NIX_BUILD = "1";

        buildInputs = [ self.openssl ];

        postInstall = ''
          mkdir -p $out/lib $out/var/empty $out/share/cached-nix-shell
          cp target/release/build/cached-nix-shell-*/out/trace-nix.so $out/lib
          cp rcfile.sh $out/share/cached-nix-shell/rcfile.sh
        '';
      };
    })
  ];
}
