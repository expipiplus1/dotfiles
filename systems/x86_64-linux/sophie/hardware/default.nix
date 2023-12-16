{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disks.nix
    ./boot.nix
  ];
  ellie.nvidia.enable = true;
  ellie.vr.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # in an ideal world
  # nixpkgs.localSystem = {
  #   gcc.arch = "znver3";
  #   gcc.tune = "znver3";
  #   system = "x86_64-linux";
  # };
}
