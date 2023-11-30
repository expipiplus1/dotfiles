{ lib, pkgs, config, ... }:
with lib;
let cfg = config.vm;
in {
  options.vm = {
    enable = mkEnableOption "vm";
    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

    users.groups.qemu-libvirtd.members = cfg.users;
    users.groups.libvirtd.members = cfg.users;

    environment.systemPackages = with pkgs; [ quickemu ];
  };
}
