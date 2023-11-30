{ lib, ... }@inputs:
lib.internal.simpleModule inputs "docker" {
  virtualisation.docker.enable = true;
  users.users.e.extraGroups = [ "docker" ];
  virtualisation.docker.daemon.settings.experimental = true;
}

