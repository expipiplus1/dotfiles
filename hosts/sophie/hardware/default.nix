{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disks.nix
    ./boot.nix
  ];

  # in an ideal world
  # nixpkgs.localSystem = {
  #   gcc.arch = "znver3";
  #   gcc.tune = "znver3";
  #   system = "x86_64-linux";
  # };

}
