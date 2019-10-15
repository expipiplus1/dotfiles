{ config, pkgs, lib, ... }:

{
  home.sessionVariables = rec {
    http_proxy = "SG-MBFC-LAN-PRX01.global.standardchartered.com:8080";
    https_proxy = http_proxy;
    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
    CORTEX_EFFECTIVE_USER_ID = builtins.getEnv "STAFFID";
  };

  programs.git.extraConfig = {
    http = { sslcainfo = config.home.sessionVariables.SSL_CERT_FILE; };
    hub = { protocol = "https"; };
  };

  programs.tmux.update-environment = lib.mkForce [ "SSH_ASKPASS" "SSH_AUTH_SOCK" "SSH_AGENT_PID" "SSH_CONNECTION" "WINDOWID" "DBUS_SESSION_BUS_ADDRESS" ];

  programs.zsh = {
    shellAliases = {
      lon = "TZ=/usr/share/zoneinfo/Europe/London date";
    };
    initExtraBeforeCompInit = ''
      j(){
        ${pkgs.atlassian-jira}/bin/jira --endpoint=https://jira.global.standardchartered.com --user="$STAFFID" "$@"
      }

      jc(){
        j create --project="$1" --issuetype=Task --override summary="$2" --override description="$3" --noedit
      }

      # Assigns to me and makes in progress
      jira-start(){
        j edit "$1" --noedit --override=assignee="'"$bankid"'" --override=reporter="'"$bankid"'"
        j transition "In Progress" "$1" --noedit
      }
    '';
    initExtra = ''
      zle-keymap-select () {
        if [ $KEYMAP = vicmd ]; then
          # the command mode for vi
          echo -ne "\e[2 q"
        else
          # the insert mode for vi
          echo -ne "\e[5 q"
        fi
      }

      # Start with insert mode cursor
      echo -ne "\e[5 q"
    '';
  };

  programs.neovim.extraConfig = ''
    set guicursor=
  '';
}
