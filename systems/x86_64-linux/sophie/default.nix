{ lib, pkgs, inputs, system
, # The system architecture for this host (eg. `x86_64-linux`).
target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
format, # A normalized name for the system target (eg. `iso`).
virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
systems, # An attribute map of your defined hosts.
config, ... }:

{
  imports = [
    ./darlings.nix
    ./hardware
    ./networking.nix
  ];
  ellie.desktop.enable = true;
  ellie.docker.enable = true;
  ellie.vm.enable = true;

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.systemPackages = with pkgs; [ lm_sensors ntfs3g ];

  nix.settings.system-features = [ "gccarch-znver3" ];

  services.earlyoom = { enable = true; };

  system.stateVersion = "21.11"; # Did you read the comment?
}
