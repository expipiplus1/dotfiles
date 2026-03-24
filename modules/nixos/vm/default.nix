{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "vm" {
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

  users.groups.qemu-libvirtd.members = [ "e" ];
  users.groups.libvirtd.members = [ "e" ];

  environment.systemPackages = with pkgs; [
    quickemu
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
  ];

  programs.dconf.enable = true;

  users.users.e.extraGroups = [ "libvirtd" ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
