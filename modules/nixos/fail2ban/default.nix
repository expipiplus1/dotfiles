{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "fail2ban" {
  services.fail2ban = {
    enable = true;
    jails = {
      nginx-botsearch = ''
        filter   = nginx-botsearch
        action = iptables-multiport[name=NGINXBOT, port=http,https, protocol=tcp]
      '';
      nginx-http-auth = ''
        filter   = nginx-http-auth
        action = iptables-multiport[name=NGINXAUTH, port=http,https, protocol=tcp]
      '';
    };
  };
}
