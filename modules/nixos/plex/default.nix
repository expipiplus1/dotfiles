{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "plex" {
  services.plex = {
    enable = true;
    openFirewall = true;
  };
}
