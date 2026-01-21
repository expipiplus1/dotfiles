{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "jellyfin" {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
