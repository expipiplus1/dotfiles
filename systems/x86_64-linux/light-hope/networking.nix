{ config, pkgs, lib, ... }:

{
  networking.hostName = "light-hope"; # Define your hostname.

  networking.networkmanager.enable = true;

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = true;
  # networking.interfaces.wlp5s0.useDHCP = true;
  # networking.interfaces.enp4s0.wakeOnLan.enable = true;
}

