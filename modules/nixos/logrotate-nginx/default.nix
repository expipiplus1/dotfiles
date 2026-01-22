{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "logrotate-nginx" {
  services.logrotate = {
    enable = true;
    settings.nginx = {
      enable = true;
      files = "/var/log/nginx/*.log";
      rotate = 2;
      frequency = "daily";
      su = "${config.services.nginx.user} ${config.services.nginx.group}";
    };
  };
}
