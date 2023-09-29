{ config, pkgs, ... }:

{
  networking.hostName = "light-hope"; # Define your hostname.

  # networking.useDHCP = false;
  # networking.interfaces.enp4s0.useDHCP = true;
  # networking.interfaces.wlp5s0.useDHCP = true;
  # networking.interfaces.enp4s0.wakeOnLan.enable = true;
}

