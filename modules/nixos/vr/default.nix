{ lib, ... }@inputs:
lib.internal.simpleModule inputs "vr" {
  #
  # todo, something similar for nvidia
  # https://github.com/NixOS/nixpkgs/issues/217119
  #
  # boot.kernelPatches = [{
  #   name = "cap_sys_nice_begone";
  #   patch = ./cap_sys_nice_begone.patch;
  # }];

  hardware.steam-hardware.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # nixpkgs.overlays = [
  #   (self: super: {
  #     steam = super.steam.override { extraPkgs = pkgs: [ pkgs.openxr-loader ]; };
  #   })
  # ];
}
