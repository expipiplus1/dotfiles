{ pkgs, ... }: {
  ellie.zsh.enable = true;
  ellie.fzf.enable = true;
  ellie.git.enable = true;
  ellie.tmux.enable = true;
  ellie.neovim.enable = true;
  ellie.kakoune.enable = true;
  ellie.helix.enable = true;
  ellie.pc.enable = true;
  ellie.gdb.enable = true;
  ellie.direnv.enable = true;
  ellie.atuin.enable = true;
  ellie.sensors.enable = true;

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
    unzip
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
    btop
    jq
    json2nix
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
      Name=Boot To Windows
      Comment=Reboot into windows
      Exec=systemctl reboot --boot-loader-entry=auto-windows
      Terminal=false
      Hidden=false
      Icon=${../../../windows.png}
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
}
