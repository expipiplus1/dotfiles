{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disks.nix
    ./boot.nix
    ./bluetooth.nix
    ./rgb.nix
  ];
  ellie.nvidia.enable = true;
  ellie.vr.enable = true;

  services.hardware.lian-li-pump-control.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # in an ideal world
  # nixpkgs.localSystem = {
  #   gcc.arch = "znver4";
  #   gcc.tune = "znver4";
  #   system = "x86_64-linux";
  # };
}
