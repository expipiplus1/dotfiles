# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "ehci_pci" "ahci" "uhci_hcd" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2a811a80-b9d6-41ec-af9e-dca08acef178";
    fsType = "btrfs";
    options = [ "subvol=nixos" ];
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/b8f4ad49-29c8-4d19-a886-cef9c487f124";
    fsType = "btrfs";
    options = [ "subvol=nixos/data" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/dfc2df67-813b-44db-bc95-3f13f6456633";
    fsType = "ext4";
  };

  swapDevices = [ ];

}
