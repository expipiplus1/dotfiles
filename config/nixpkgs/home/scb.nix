{ config, pkgs, ... }:

{
  home.sessionVariables = rec {
    http_proxy = "SG-MBFC-LAN-PRX01.global.standardchartered.com:8080";
    https_proxy = http_proxy;
    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
  };

  programs.git.extraConfig = {
    http = { sslcainfo = config.home.sessionVariables.SSL_CERT_FILE; };
    hub = { protocol = "https"; };
  };

  programs.tmux.update-environment = [ "SSH_ASKPASS" "SSH_AUTH_SOCK" "SSH_AGENT_PID" "SSH_CONNECTION" "WINDOWID" "DBUS_SESSION_BUS_ADDRESS" ];

  programs.zsh.initExtra = ''
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
}
