{ config, pkgs, lib, ... }:

{
  imports = [
    ./home/zsh.nix
    ./home/fish.nix
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
    bat
    bmon
    cached-nix-shell
    coreutils
    curl
    dnsutils
    du-dust
    efibootmgr
    entr
    fd
    file
    fzf
    gist
    htop
    jq
    killall
    mosh
    nix
    nix-prefetch-git
    nix-prefetch-github
    nmap
    openssl
    silver-searcher
    tio
    tree
    tssh
    yq
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
    "autostart/setxkb-helper.desktop".source = pkgs.writeTextFile {
      name = "setxkb-helper.desktop";
      text = ''
        [Desktop Entry]
        Type=Application
        Exec=${
          pkgs.writeShellScript "setxkb-helper" ''
            sleep 2
            setxkbmap -verbose 10 fc660c -types fc660c 2>&1
            gdbus monitor -y -d org.freedesktop.login1 | while read l; do
              grep -q "'LockedHint': <false>" <<< $l || continue
              sleep 2
              setxkbmap -verbose 10 fc660c -types fc660c 2>&1
            done
          ''
        }
        Hidden=false
        X-GNOME-Autostart-enabled=true
        Name=setxkb-helper
      '';
    };
  } // autostart "firefox"
  // autostart "spotify"
  // autostart "alacritty --command bash -i -c 'tmux attach'";

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
          ${self.mosh}/bin/mosh --server=.nix-profile/bin/mosh-server "$@" -- .nix-profile/bin/tmux attach
        '';
        executable = true;
        destination = "/bin/tssh";
      };
      cached-nix-shell = import (self.fetchFromGitHub {
        owner = "xzfc";
        repo = "cached-nix-shell";
        rev = "0e73944dc31132d2aa9a769f4cc677eea6984bec";
        sha256 = "1hzrjvxk9rpqdxw0v27ngn5k3andm1xfkak4ly75x6gxwgb5mdw5";
      }) { pkgs = self; };
      spotify = super.spotify.overrideAttrs (old: {
        postInstall = ''
          sed -i 's/^Exec=spotify/Exec=spotify --force-device-scale-factor=2/' "$out/share/applications/spotify.desktop"
        '';
      });
    })
  ];
}
