{ config, lib, pkgs, modulesPath, ... }:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1ce5a14e-4cbb-4a39-95f8-4444b33f7ab5";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/1ce5a14e-4cbb-4a39-95f8-4444b33f7ab5";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/1ce5a14e-4cbb-4a39-95f8-4444b33f7ab5";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/1ce5a14e-4cbb-4a39-95f8-4444b33f7ab5";
      fsType = "btrfs";
      options = [ "subvol=persist" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/1ce5a14e-4cbb-4a39-95f8-4444b33f7ab5";
      fsType = "btrfs";
      options = [ "subvol=log" ];
      neededForBoot = true;
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/543E-21E5";
      fsType = "vfat";
    };
}
