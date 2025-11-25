{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "vr" {
  #
  # todo, something similar for nvidia
  # https://github.com/NixOS/nixpkgs/issues/217119
  #
  # boot.kernelPatches = [{
  #   name = "cap_sys_nice_begone";
  #   patch = ./cap_sys_nice_begone.patch;
  # }];

  # boot.kernelPatches = [{
  #   name = "amdgpu-ignore-ctx-privileges";
  #   patch = pkgs.fetchpatch {
  #     name = "cap_sys_nice_begone.patch";
  #     url =
  #       "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
  #     hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
  #   };
  # }];

  hardware.steam-hardware.enable = true;
  hardware.graphics.enable32Bit =
    if config.ellie.nvidia.devDriver then false else true;

  # nixpkgs.overlays = [
  #   (self: super: {
  #     steam = super.steam.override { extraPkgs = pkgs: [ pkgs.openxr-loader ]; };
  #   })
  # ];
}
