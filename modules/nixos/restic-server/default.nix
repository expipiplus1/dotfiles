{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "restic-server" {
  services.restic.server = {
    enable = true;
    dataDir = "/data/restic";
    privateRepos = true;
    appendOnly = true;
  };
  systemd.services.restic-rest-server.after = [ "local-fs.target" ];
}
