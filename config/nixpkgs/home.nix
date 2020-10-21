{ config, pkgs, lib, ... }:

let
  spotifyCommand = "spotify --force-device-scale-factor=2";

  ymlfmt = pkgs.stdenv.mkDerivation {
    name = "ymlfmt";
    buildInputs = [
      (pkgs.python3.withPackages
        (pythonPackages: with pythonPackages; [ ruamel_yaml ]))
    ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cat > "$out/bin/ymlfmt" << EOF
      #!/usr/bin/env python
      import sys
      from ruamel import yaml
      yaml.round_trip_dump(yaml.round_trip_load(sys.stdin), sys.stdout)
      EOF
      chmod +x "$out/bin/ymlfmt"
    '';
  };

in {
  imports = [
    ./home/zsh.nix
    # ./home/fish.nix
    ./home/fzf.nix
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
    perl
    silver-searcher
    tio
    tree
    tssh
    yq
  ];

  xdg.dataFile."applications/windows.desktop".source = pkgs.writeTextFile {
    name = "windows.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Boot To Windows Next
      Comment=Set this computer to start Windows after rebooting
      Exec=sh -c 'pkexec efibootmgr --bootnext 0000 && reboot'
      Terminal=false
      Hidden=false
      Icon=/home/j/Downloads/windows.png
    '';
  };

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
  } // autostart "firefox" // autostart "${spotifyCommand}"
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
          sed -i 's/^Exec=spotify/Exec=${spotifyCommand}/' "$out/share/applications/spotify.desktop"
        '';
      });
      ymlfmt = ymlfmt;
    })
  ];
}
