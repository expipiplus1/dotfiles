{ lib, pkgs, inputs, system
, # The system architecture for this host (eg. `x86_64-linux`).
target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
format, # A normalized name for the system target (eg. `iso`).
virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
systems, # An attribute map of your defined hosts.
config, ... }:

{
  imports = [ ./impermanence.nix ./hardware ./networking.nix ];
  ellie.desktop.enable = true;
  ellie.docker.enable = true;
  ellie.vm.enable = true;
  personal.dslr-webcam = {
    enable = true;
    virtual-device-name = "a7iii";
    camera-udev-product = "54c/c34/200";
    ffmpeg-hwaccel = false;
  };

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix.settings.system-features = [ "gccarch-znver4" ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
