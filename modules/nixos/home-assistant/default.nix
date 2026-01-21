{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "home-assistant" {
  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.home-assistant = {
    enable = true;
    config = {
      default_config = { };
      script = "!include scripts.yaml";
      automation = "!include automations.yaml";
      broadlink = { };
      backup = { };
      zha = { };
      smartir = { };
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
    };
  };
}
