{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "basic" {
  home.username = "e";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
  home.homeDirectory = "/home/e";

  nix.package = pkgs.nix;
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    NIX_PATH = "nixpkgs=$HOME/src/nixpkgs";
    EDITOR = "vim";
    NIXOS_OZONE_WL = 1;
    SSH_ASKPASS_REQUIRE = "prefer";
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };

  home.packages = with pkgs; [
    # Cross-platform clipboard scripts
    (let
      cmd = if stdenv.isDarwin then "pbcopy" else ''
        if [[ -n "$WSL_DISTRO_NAME" ]]; then clip.exe
        elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then ${wl-clipboard}/bin/wl-copy
        else ${xclip}/bin/xclip -selection clipboard -in; fi
      '';
    in writeShellScriptBin "copy" cmd)
  
    (let
      cmd = if stdenv.isDarwin then "pbpaste" else ''
        if [[ -n "$WSL_DISTRO_NAME" ]]; then powershell.exe -Command Get-Clipboard
        elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then ${wl-clipboard}/bin/wl-paste
        else ${xclip}/bin/xclip -selection clipboard -out; fi
      '';
    in writeShellScriptBin "pasta" cmd)

    bat
    bear
    bmon
    btop
    cached-nix-shell
    coreutils
    curl
    difftastic
    dnsutils
    dust
    duf
    entr
    fd
    file
    gh
    gist
    hackage-release
    htop
    jq
    # json2nix
    killall
    lsd
    mosh
    nix
    nix-output-monitor
    nix-prefetch-git
    nix-prefetch-github
    nmap
    openssl
    perl
    ripgrep
    rust-parallel
    silver-searcher
    tio
    tree
    tssh
    unzip
    yq
    ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    lm_sensors
    efibootmgr
  ];

  xdg.configFile = {
    "yamllint/config".source = pkgs.writeTextFile {
      name = "yamllint-config";
      text = builtins.toJSON {
        extends = "relaxed";
        rules.line-length.max = 120;
      };
    };
    "sccache/config".text =
      builtins.concatStringsSep "\n" [ "[cache.disk]" "size = 100000000000" ];
  };
}
