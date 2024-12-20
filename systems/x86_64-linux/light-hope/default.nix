{ lib, pkgs, inputs, system
, # The system architecture for this host (eg. `x86_64-linux`).
target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
format, # A normalized name for the system target (eg. `iso`).
virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
systems, # An attribute map of your defined hosts.
config, ... }:

{
  networking.hostName = "light-hope"; # Define your hostname.
  imports = [ ./impermanence.nix ./hardware ];
  ellie.desktop.enable = true;
  ellie.ollama.enable = true;
  ellie.nvidia.devDriver = true;
  nix.settings.system-features = [ "gccarch-znver4" ];
  system.stateVersion = "23.11"; # Did you read the comment?

  programs.mosh.enable = true;
}
