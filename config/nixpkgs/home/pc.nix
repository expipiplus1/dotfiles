{ pkgs, ... }:

{
  imports = [ ./tex.nix ./haskell.nix ./coc-nvim.nix ./alacritty.nix ];

  home.packages = with pkgs; [
    ffmpeg-full
    powerline-fonts
    xsel
    vscode
    signal-desktop
    firefox
    spotify
    darktable
    opentx
    element-desktop
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
            projects src/nixpkgs* src/prints dotfiles Pictures work .ssh \
            --exclude .stack-work \
            --exclude dist-newstyle
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
