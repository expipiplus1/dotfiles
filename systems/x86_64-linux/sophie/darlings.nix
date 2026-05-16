{ config, lib, pkgs, ... }:

{
  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
    adjtime.source = lib.mkForce "/persist/etc/adjtime";
    NIXOS.source = "/persist/etc/NIXOS";
    machine-id.source = "/persist/etc/machine-id";
    "nix/private-key".source = "/persist/etc/nix/sophie.secret";
    "tailscale/auth-key".source = "/persist/etc/secrets/tailscale-auth";
  };
  systemd.tmpfiles.rules = [
    "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
    "L /var/lib/NetworkManager/seen-bssids - - - - /persist/var/lib/NetworkManager/seen-bssids"
    "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"
  ];
  fileSystems."/var/lib/bluetooth" = {
    device = "/persist/var/lib/bluetooth";
    fsType = "none";
    options = [ "bind" "noauto" "x-systemd.automount" ];
    noCheck = true;
  };
  fileSystems."/var/lib/tailscale" = {
    device = "/persist/var/lib/tailscale";
    fsType = "none";
    options = [ "bind" "noauto" "x-systemd.automount" ];
    noCheck = true;
  };
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  services.openssh = {
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };


  boot.initrd.systemd.services.rollback-root = {
    description = "Rollback btrfs root to blank snapshot";
    wantedBy = [ "initrd.target" ];
    after = [ "local-fs-pre.target" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt

      # We first mount the btrfs root to /mnt
      # so we can manipulate btrfs subvolumes
      mount -o subvol=/ ${config.fileSystems."/".device} /mnt

      # /root is already populated at this point with subvolumes
      # (e.g. /root/var/lib/portables, /root/var/lib/machines),
      # which makes `btrfs subvolume delete` fail.
      # So, we remove them first.
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
  };
}
