{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "vm" {
    virtualisation.libvirtd.enable = true;
    boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

    users.groups.qemu-libvirtd.members = ["e"];
    users.groups.libvirtd.members = ["e"];

    environment.systemPackages = with pkgs; [ quickemu ];
}
