{ config, pkgs, ... }:

{
  home.sessionVariables = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
  };

  programs.git.extraConfig = {
    http = { sslcainfo = config.home.sessionVariables.SSL_CERT_FILE; };
    hub = { protocol = "https"; };
  };
}
