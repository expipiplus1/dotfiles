{ config, pkgs, lib, ... }:

{
  networking.hostName = "sophie"; # Define your hostname.
  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp4s0.wakeOnLan.enable = true;
}

