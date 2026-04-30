{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/abd62adf-2713-4dba-aed1-0ac04038a8bd";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/37A1-93CB";
    fsType = "vfat";
  };
}
