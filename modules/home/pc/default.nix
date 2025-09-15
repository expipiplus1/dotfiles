{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "pc" {
  ellie.tex.enable = true;
  ellie.haskell.enable = true;
  ellie.foot.enable = true;
  ellie.alacritty.enable = true;
  ellie.wezterm.enable = true;
  ellie.kitty.enable = true;
  # This segfaults on install?
  ellie.plasma.enable = true;

  home.packages = with pkgs; [
    anki
    darktable
    element-desktop
    ffmpeg-full
    firefox
    opentx
    pinta
    powerline-fonts
    signal-desktop
    telegram-desktop
    tg
    thunderbird
    tidal-hifi
    vlc
    wl-clipboard
    xsel
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
    # vscodium 1.80 doesn't seem to work on wayland
    # package = pkgs-stable.vscodium;
    package = pkgs.vscodium;
    profiles.default = {
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      extensions = with pkgs;
        with vscode-extensions; [
          ms-vscode.cpptools
          asvetliakov.vscode-neovim
          justusadam.language-haskell
          arcticicestudio.nord-visual-studio-code
          haskell.haskell
        ];
      userSettings = {
        keyboard.dispatch = "keyCode";
        vscode-neovim.neovimExecutablePaths.linux =
          "/home/e/.nix-profile/bin/nvim";
        haskell.manageHLS = "PATH";
        haskell.formattingProvider = "fourmolu";
        haskell.openDocumentationInHackage = false;
        haskell.openSourceInHackage = false;
        window.zoomLevel = -2;
        "workbench.colorTheme" = "Nord";
        "workbench.colorCustomizations"."[Nord]" = {
          "editor.focusedStackFrameHighlightBackground" = "#a3be8c33";
          "editor.stackFrameHighlightBackground" = "#ebcb8b33";
          "editorGroupHeader.noTabsBackground" = "#3b4252";
          "editorGroupHeader.tabsBackground" = "#3b4252";
          "tab.activeBackground" = "#2e3440";
          "tab.inactiveBackground" = "#3b4252";
          "tab.hoverBackground" = "#2e3440";
          "tab.unfocusedHoverBackground" = "#434c5eb3";
        };
        editor.fontFamily = "Iosevka Term";
        editor.fontLigatures = "'calt' off, 'dlig' off, 'cv57' 2, 'cv36' 1";
        C_Cpp.intelliSenseEngine = "disabled";
        debug.onTaskErrors = "abort";
        # Hide decorations on wayland
        window.titleBarStyle = "custom";
      };
    };
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
            src/prints dotfiles work \
            .local/share/Anki2 \
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
