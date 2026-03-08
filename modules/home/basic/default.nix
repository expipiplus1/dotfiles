{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "basic" {
  home.username = "e";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
  home.homeDirectory = "/home/e";

  nix.package = pkgs.nix;
  nix.extraOptions = "extra-deprecated-features = or-as-identifier";
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    NIX_PATH = "nixpkgs=$HOME/src/nixpkgs";
    EDITOR = "vim";
    NIXOS_OZONE_WL = 1;
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  home.packages = with pkgs; [
    # Cross-platform clipboard copy
    (writeShellScriptBin "copy" ''
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        pbcopy
      elif [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$WSL_INTEROP" ]]; then
        # WSL
        clip.exe
      elif [[ "$XDG_SESSION_TYPE" == "wayland" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
        # Wayland
        ${wl-clipboard}/bin/wl-copy
      else
        # X11
        ${xclip}/bin/xclip -selection clipboard -in
      fi
    '')
    # Cross-platform clipboard paste
    (writeShellScriptBin "pasta" ''
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        pbpaste
      elif [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$WSL_INTEROP" ]]; then
        # WSL
        powershell.exe -Command Get-Clipboard
      elif [[ "$XDG_SESSION_TYPE" == "wayland" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
        # Wayland
        ${wl-clipboard}/bin/wl-paste
      else
        # X11
        ${xclip}/bin/xclip -selection clipboard -out
      fi
    '')

    bat
    bear
    bmon
    btop
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
    gh
    gist
    hackage-release
    htop
    jq
    # json2nix
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
    ripgrep
    rust-parallel
    silver-searcher
    tio
    tree
    tssh
    unzip
    yq
    # claude-server
  ];

  xdg.configFile = {
    "yamllint/config".source = pkgs.writeTextFile {
      name = "yamllint-config";
      text = builtins.toJSON {
        extends = "relaxed";
        rules.line-length.max = 120;
      };
    };
    "sccache/config".text = builtins.concatStringsSep "\n" [
      "[cache.disk]"
      "size = 100000000000"
    ];
  };
}
