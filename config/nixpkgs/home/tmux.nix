{ config, pkgs, lib, ... }:

{
  options.programs.tmux.update-environment = with lib; mkOption {
    default = null;
    type = types.nullOr (types.listOf types.str);
    description = ''
      A list of environment variables to pass to
      `update-environment`
    '';
    example = [ "DBUS_SESSION_BUS_ADDRESS" ];
  };

  config = {
    programs.zsh.oh-my-zsh.plugins = [ "tmux" ];

    programs.tmux = {
      enable = true;
      shortcut = "space";
      newSession = true;
      shell = pkgs.zsh + "/bin/zsh";
      baseIndex = 1;
      clock24 = true;
      historyLimit = 40000;
      keyMode = "vi";
      update-environment = [ "DISPLAY" "SSH_ASKPASS" "SSH_AUTH_SOCK" "SSH_AGENT_PID" "SSH_CONNECTION" "WINDOWID" "XAUTHORITY" "DBUS_SESSION_BUS_ADDRESS" ];
      terminal = "screen-256color";
      secureSocket = false;
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            # resurrection settings
            set -g @resurrect-save 'S'
            set -g @resurrect-restore 'R'

            # for vim
            set -g @resurrect-strategy-vim 'session'
            # for neovim
            set -g @resurrect-strategy-nvim 'session'

            set -g @resurrect-capture-pane-contents 'on'

            set -g @resurrect-processes '~vi ~vim ~nvim ~man ~less ~more ~tail ~top ~htop ~irssi ~mutt'
          '';
        }
      ];
      extraConfig = ''
        # Something sensible
        set-option -g default-shell ~/.nix-profile/bin/zsh

        set-option -g -q mouse on

        # Resize with Shift-arrow
        bind-key -n S-Up resize-pane -U 15
        bind-key -n S-Down resize-pane -D 15
        bind-key -n S-Left resize-pane -L 25
        bind-key -n S-Right resize-pane -R 25

        bind-key -T root PPage if-shell -F "#{alternate_on}" "send-keys PPage" "copy-mode -e; send-keys PPage"
        bind-key -Tcopy-mode-vi PPage send -X page-up
        bind-key -Tcopy-mode-vi NPage send -X page-down

        bind-key -T root WheelUpPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
        bind-key -T root WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"
        bind-key -Tcopy-mode-vi WheelUpPane send -X halfpage-up
        bind-key -Tcopy-mode-vi WheelDownPane send -X halfpage-down

        # Focus events for vim
        set-option -g focus-events on

        # don't delay escape key
        set -sg escape-time 0

        # vi vi vi
        set -g mode-keys vi
        bind-key -Tcopy-mode-vi 'v' send -X begin-selection
        bind-key -Tcopy-mode-vi 'y' send -X copy-pipe-and-cancel '${pkgs.xsel}/bin/xsel -i --clipboard'
        # move x clipboard into tmux paste buffer
        bind C-p run "${config.programs.tmux.package}/bin/tmux set-buffer \"$(${pkgs.xsel}/bin/xsel -o --clipboard)\"; ${config.programs.tmux.package}/bin/tmux paste-buffer"
        # move tmux copy buffer into x clipboard
        bind C-y run "${config.programs.tmux.package}/bin/tmux show-buffer | ${pkgs.xsel}/bin/xsel -i --clipboard"

        # no status bar
        set -g status off

        # Smart pane switching with awareness of vim splits and nested tmux sessions
        is_vim='${config.programs.tmux.package}/bin/tmux display -p #{pane_current_command} | grep -iqE "(^|\/)\.?g?(view|n?vim?)(diff)?(-wrapped)?$"'
        is_tmux='${config.programs.tmux.package}/bin/tmux display -p #{pane_pid} | xargs ps h -oargs --ppid | grep -q "tssh"'
        is_paned="$is_vim || $is_tmux"
        bind -n C-h if-shell "$is_paned" "send-keys C-h" "select-pane -L"
        bind -n C-j if-shell "$is_paned" "send-keys C-j" "select-pane -D"
        bind -n C-k if-shell "$is_paned" "send-keys C-k" "select-pane -U"
        bind -n C-l if-shell "$is_paned" "send-keys C-l" "select-pane -R"
        bind -n C-\ if-shell "$is_paned" "send-keys C-\\" "select-pane -l"

        # Smart window splitting with awareness of vim
        bind s   if-shell "$is_paned" "send-keys C-${config.programs.tmux.shortcut} s"   "split-window -v -c '#{pane_current_path}'"
        bind v   if-shell "$is_paned" "send-keys C-${config.programs.tmux.shortcut} v"   "split-window -h -c '#{pane_current_path}'"

        bind '"' split-window -c '#{pane_current_path}'
        bind % split-window -h -c '#{pane_current_path}'
        bind C-s split-window -c '#{pane_current_path}'
        bind C-v split-window -h -c '#{pane_current_path}'
        bind c new-window -c '#{pane_current_path}'
        bind C-c new-window -c '#{pane_current_path}'

        # Clear on C-k
        bind C-k send-keys -R \; send-keys C-l \; clear-history

        # Automatically set window title
        set-window-option -g automatic-rename on
        set-option -g set-titles on

        # Hilight current window
        # Works well with base16 colors
        set-window-option -g window-active-style 'bg=black'
        set-window-option -g window-style 'bg=colour18'
        set-window-option -g pane-active-border-style ''''''

        # Renumber windows
        set-option -g renumber-windows on

        # don't use ansi colors
        # set -as terminal-overrides ",*-256color:setaf@:setab@"
        set -ga terminal-overrides ',xterm-256color:Tc'

        set -g set-clipboard off

        # C-c: save into system clipboard (+). With preselection.
        bind C-c choose-buffer "run \"${config.programs.tmux.package}/bin/tmux save-buffer -b %% - | ${pkgs.xsel}/bin/xsel -i --clipboard\" \; run \" ${config.programs.tmux.package}/bin/tmux display \\\"Clipboard \(+\) filled with: $(${config.programs.tmux.package}/bin/tmux save-buffer -b %1 - | dd ibs=1 obs=1 status=noxfer count=80 2> /dev/null)... \\\" \" "

        # from https://gist.github.com/towo/b5643ba96f987df54acc54470e6be460
        ${lib.optionalString (config.programs.tmux.update-environment != null) ''
        set -g update-environment '${lib.concatStringsSep " " config.programs.tmux.update-environment}'
        ''}
      '';
    };
  };
}
