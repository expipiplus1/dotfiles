{ config, lib, pkgs, modulesPath, ... }:

let
  opts = subvol: [
    "subvol=${subvol}"
    "compress=zstd"
    "noatime"
    "discard=async"
  ];
  rootUUID = "1ce5a14e-4cbb-4a39-95f8-4444b33f7ab5";
in {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${rootUUID}";
    fsType = "btrfs";
    options = opts "root";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/${rootUUID}";
    fsType = "btrfs";
    options = opts "home";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${rootUUID}";
    fsType = "btrfs";
    options = opts "nix";
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/${rootUUID}";
    fsType = "btrfs";
    options = opts "persist";
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/${rootUUID}";
    fsType = "btrfs";
    options = opts "log";
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/543E-21E5";
    fsType = "vfat";
  };
}
