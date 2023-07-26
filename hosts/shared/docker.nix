{ config, pkgs, ... }: {
  virtualisation.docker.enable = true;
  users.users.e.extraGroups = [ "docker" ];
}
