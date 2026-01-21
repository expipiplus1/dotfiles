{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "nginx-server" {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    defaults.email = "acme@sub.monoid.al";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    appendHttpConfig = ''
      server_names_hash_bucket_size 64;
    '';
  };
}
