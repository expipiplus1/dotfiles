{ config, lib, pkgs, modulesPath, ... }:

{
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/538331b2-129c-4fc3-adc4-7f7055373b04";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/538331b2-129c-4fc3-adc4-7f7055373b04";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/538331b2-129c-4fc3-adc4-7f7055373b04";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/538331b2-129c-4fc3-adc4-7f7055373b04";
    fsType = "btrfs";
    options = [ "subvol=persist" "compress=zstd" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/538331b2-129c-4fc3-adc4-7f7055373b04";
    fsType = "btrfs";
    options = [ "subvol=log" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3E4E-B10D";
    fsType = "vfat";
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/f1b3d1c6-869b-4aa0-8242-be2669bbfc27";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" ];
  };

  fileSystems."/windows" = {
    device = "/dev/disk/by-uuid/2A025B09025ADA01";
    fsType = "ntfs";
    options = [ "x-systemd.automount" ];
  };

  fileSystems."/windows-data" = {
    device = "/dev/disk/by-uuid/5CF8C1CAF8C1A31E";
    fsType = "ntfs";
    options = [ "x-systemd.automount" ];
  };
}
