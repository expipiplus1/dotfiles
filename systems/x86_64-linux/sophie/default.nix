{ lib, pkgs, inputs, system
, # The system architecture for this host (eg. `x86_64-linux`).
target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
format, # A normalized name for the system target (eg. `iso`).
virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
systems, # An attribute map of your defined hosts.
config, ... }:

{
  networking.hostName = "sophie"; # Define your hostname.
  imports = [ ./darlings.nix ./hardware ];
  ellie.desktop.enable = true;
  nix.settings.system-features = [ "gccarch-znver3" ];
  networking.interfaces.enp4s0.wakeOnLan.enable = true;
  services.earlyoom = { enable = true; };
  system.stateVersion = "21.11"; # Did you read the comment?
}
