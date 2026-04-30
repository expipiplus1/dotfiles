{ lib, pkgs, config, modulesPath, ... }@inputs:
lib.internal.simpleModule inputs "oci" {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # OCI-specific kernel params (from nixpkgs oci-common.nix)
  boot.kernelParams = [
    "nvme.shutdown_timeout=10"
    "nvme_core.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"
    "console=tty1"
    "console=ttyS0"
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];

  # OCI NTP
  networking.timeServers = [ "169.254.169.254" ];
  networking.useNetworkd = lib.mkDefault true;

  nix.settings.max-jobs = lib.mkDefault 2;
}
