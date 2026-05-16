{ lib, config, ... }@inputs:
lib.internal.simpleModule inputs "low-disk-space" {
  nix.settings.auto-optimise-store = true;
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.extraOptions = ''
    min-free = ${toString (512 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';
}
