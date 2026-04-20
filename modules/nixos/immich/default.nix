{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "immich" {
  services.immich = {
    enable = true;
    mediaLocation = "/data/immich";
  };

  systemd.tmpfiles.settings.immich-media."/data/immich".d = {
    user = "immich";
    group = "immich";
    mode = "0700";
  };

  services.nginx.virtualHosts."immich.home.monoid.al" = {
    useACMEHost = "monoid.al";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2283";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        client_max_body_size 0;
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
        send_timeout 600;
      '';
    };
  };
}
