{ config, pkgs, ... }:

let
  quoth-dir = "/var/quoth";
  quoth-port = 4747;
  quoth = let
    src = builtins.fetchTarball {
      url =
        "https://github.com/expipiplus1/quoth-the-enterprise/archive/43aa8810539d3d53140904a9fa85b25eb9519bc8.tar.gz"; # master
      sha256 = "1zl9f8mndjh2jbpmzjng05mb2jd2f5rpijmgc9kgxlyhqpyhgzvb";
    };
  in import src { };

in {
  services.nginx = {
    commonHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=default:10m rate=120r/m;
    '';
    virtualHosts = {
      "home.monoid.al" = {
        locations = {
          "/quote" = {
            proxyPass = "http://localhost:${toString quoth-port}";
            extraConfig = ''
              auth_basic off;
              limit_req zone=default burst=5;
            '';
          };
        };
      };
    };
  };

  # Largely from https://github.com/NixOS/nixpkgs/issues/89559
  # TODO: get this to start on the socket
  systemd.services.quoth = {
    enable = false;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
    environment = { LANG = "en_US.iso88591"; };
    path = [ quoth pkgs.findutils ];
    script = ''
      quoth --port ${toString quoth-port} $(find "${quoth-dir}" -iname '*.htm')
    '';
  };
}
