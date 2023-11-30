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
      (rootd "/etc/NetworkManager/system-connections" "0700")
      (rootd "/var/lib/bluetooth" "0700")
      (rootd "/var/lib/alsa" "0755")

      {
        directory = "/var/cache/private/nixseparatedebuginfod";
        user = "nixseparatedebuginfod";
        group = "nixseparatedebuginfod";
        mode = "0755";
      }
    ];
    files = [
      "/etc/adjtime"
      "/etc/machine-id"
      "/etc/nix/private-key"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];
  };

  # https://github.com/chayleaf/dotfiles/blob/f77271b249e0c08368573c22a5c34f0737d3a766/system/modules/impermanence.nix
  # Should add these services maybe?

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  ################################################################
  # rollback
  ################################################################

  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt

    # We first mount the btrfs root to /mnt
    # so we can manipulate btrfs subvolumes.
    mount -o subvol=/ ${config.fileSystems."/".device} /mnt

    # While we're tempted to just delete /root and create
    # a new snapshot from /root-blank, /root is already
    # populated at this point with a number of subvolumes,
    # which makes `btrfs subvolume delete` fail.
    # So, we remove them first.
    #
    # /root contains subvolumes:
    # - /root/var/lib/portables
    # - /root/var/lib/machines
    #
    # I suspect these are related to systemd-nspawn, but
    # since I don't use it I'm not 100% sure.
    # Anyhow, deleting these subvolumes hasn't resulted
    # in any issues so far, except for fairly
    # benign-looking errors from systemd-tmpfiles.
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

    # Once we're done rolling back to a blank snapshot,
    # we can unmount /mnt and continue on the boot process.
    umount /mnt
  '';
}
