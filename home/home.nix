{ config, pkgs, lib, ... }:

let
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
    ./zsh.nix
    # ./fish.nix
    ./fzf.nix
    ./git.nix
    ./tmux.nix
    ./neovim.nix
    ./kakoune.nix
    ./helix.nix
    ./pc.nix
    ./gdb.nix
    ./direnv.nix
    ./atuin.nix
  ];

  home.username = "e";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
  home.homeDirectory = "/home/e";

  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    NIX_PATH = "nixpkgs=$HOME/src/nixpkgs";
    EDITOR = "vim";
    NIXOS_OZONE_WL = 1;
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  home.packages = with pkgs; [
    bat
    bear
    bmon
    cached-nix-shell
    coreutils
    curl
    difftastic
    dnsutils
    du-dust
    duf
    efibootmgr
    entr
    fd
    file
    gist
    hackage-release
    htop
    jq
    killall
    lm_sensors
    lsd
    mosh
    nix
    nix-output-monitor
    nix-prefetch-git
    nix-prefetch-github
    nmap
    openssl
    perl
    rust-analyzer
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
      Exec=sh -c 'pkexec efibootmgr --bootnext 0002 && reboot'
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
    "yamllint/config".source = pkgs.writeTextFile {
      name = "yamllint-config";
      text = builtins.toJSON {
        extends = "relaxed";
        rules.line-length.max = 120;
      };
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
            sleep 20
            setxkbmap -verbose 10 fc660c -types fc660c 2>&1
            gdbus monitor -y -d org.freedesktop.login1 | while read l; do
              grep -q "'LockedHint': <false>" <<< $l || continue
              sleep 2
              setxkbmap -verbose 10 fc660c -types fc660c 2>&1
              sleep 20
              setxkbmap -verbose 10 fc660c -types fc660c 2>&1
            done
          ''
        }
        Hidden=false
        X-GNOME-Autostart-enabled=true
        Name=setxkb-helper
      '';
    };
  } // autostart "firefox" // autostart "tidal-hifi"
  // autostart "foot -- zsh -i -c tmux attach" // autostart "element-desktop";

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
      hackage-release = self.writeShellScriptBin "hackage-release" ''
        ${pkgs.gitAndTools.hub}/bin/hub release download "$1" |
          cut -d' ' -f2 |
          sort -r |
          while read f; do
            if [[ "$f" =~ "-docs.tar.gz" ]]; then
              ${pkgs.cabal-install}/bin/cabal upload --publish --doc "$f"
            else
              ${pkgs.cabal-install}/bin/cabal upload --publish "$f"
            fi
            rm "$f"
          done
      '';
      inherit ymlfmt;
      fzf = super.fzf.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "expipiplus1";
          repo = "fzf";
          rev = "ad12372681ec1a49c6d788e6c9a64c247293ed04"; # tmux-popup
          sha256 = "1c32bgi9y3j2v6734dksyxpxzprdqklycz34hsh8scja5sd293h0";
        };
      });
    })
  ];
}
