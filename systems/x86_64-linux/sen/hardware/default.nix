{ config, lib, modulesPath, pkgs, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3604511d-9883-4045-9f7e-bb49ed1be42c";
    fsType = "ext4";
  };

  fileSystems."/mnt/synapse-media" = {
    device = "/dev/disk/by-id/scsi-0Linode_Volume_synapse-media";
    fsType = "btrfs";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/8af325d4-31b1-4274-a57c-72d708589360"; }
    { device = "/swapfile"; }
  ];

  nix.settings.max-jobs = lib.mkDefault 1;
}
