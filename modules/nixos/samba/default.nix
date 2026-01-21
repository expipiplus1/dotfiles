{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "samba" {
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "hosts allow" = "192.168.1. localhost";
        "hosts deny" = "0.0.0.0/0";
        "map to guest" = "Bad User";
        "get quota command" = "${
            pkgs.writeScript "smb-quota.sh" ''
              #!${pkgs.bash}/bin/bash
              echo "0 0 0 0 0 0 0"
            ''
          }";
      };
    };
  };
}
