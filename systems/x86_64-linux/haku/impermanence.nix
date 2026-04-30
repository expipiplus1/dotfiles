{ pkgs, config, ... }:
let
  rootd = d: m: {
    directory = d;
    user = "root";
    group = "root";
    mode = m;
  };

in {
  users.mutableUsers = false;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      (rootd "/etc/nixos" "0755")
      (rootd "/var/lib/nixos" "0755")
      (rootd "/var/lib/systemd" "0755")
      (rootd "/var/lib/fail2ban" "0755")
      (rootd "/var/log" "0755")
    ];
    files = [
      "/etc/adjtime"
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  ################################################################
  # rollback
  ################################################################

  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt

    mount -o subvol=/ /dev/disk/by-label/nixos /mnt

    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done &&
    echo "deleting /root subvolume..." &&
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    umount /mnt
  '';
}
