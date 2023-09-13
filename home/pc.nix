{ pkgs, ... }:

{
  imports =
    [ ./tex.nix ./haskell.nix ./alacritty.nix ./wezterm.nix ./kitty.nix ];

  home.packages = with pkgs; [
    ffmpeg-full
    powerline-fonts
    xsel
    signal-desktop
    firefox
    tidal-hifi
    darktable
    opentx
    element-desktop
    pinta
    gnomeExtensions.freon
    gnomeExtensions.control-blur-effect-on-lock-screen
    gnomeExtensions.hide-activities-button
    gnomeExtensions.unite
    gnomeExtensions.dash-to-panel
    gnomeExtensions.shell-configurator
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      open-browser-vim
      open-browser-github-vim
    ];
  };

  programs.tmux = { plugins = [ pkgs.tmuxPlugins.open ]; };

  programs.zsh = {
    initExtraBeforeCompInit = ''
      wd() {
        nix-store -q --graph "$1" |
          ${pkgs.graphviz}/bin/dijkstra -da "$2" |
          ${pkgs.graphviz}/bin/gvpr -c 'N[dist>1000.0]{delete(NULL, $)}' |
          ${pkgs.graphviz}/bin/dot -Tsvg |
          ${pkgs.imagemagick}/bin/display
      }
    '';
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs;
      with vscode-extensions; [
        ms-vscode.cpptools
        haskell.haskell
        asvetliakov.vscode-neovim
        justusadam.language-haskell
      ];
  };

  systemd.user = {
    services.restic = {
      Unit.Description = "Perform restic backup";
      Service = {
        Type = "oneshot";
        ExecStart = toString (pkgs.writeShellScript "restic" ''
          export RESTIC_REPOSITORY_FILE=$HOME/.ssh/restic/repo
          export RESTIC_PASSWORD_FILE=$HOME/.ssh/restic/password
          ${pkgs.restic}/bin/restic \
            backup \
            --one-file-system \
            Documents projects src/nixpkgs* \
            src/prints dotfiles Pictures work \
            .gnupg .ssh \
            .zsh_history \
            --exclude .stack-work \
            --exclude dist-newstyle \
            --exclude bin \
            --exclude intermediate \
            --exclude build
        '');
      };
    };

    timers.restic = {
      Unit.Description = "Timer for backup";
      Timer = {
        Unit = "restic.service";
        AccuracySec = "60s";
        OnCalendar = "hourly";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}