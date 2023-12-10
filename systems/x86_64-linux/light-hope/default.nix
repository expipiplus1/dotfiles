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

  ellie.dm.enable = true;
  ellie.kde.enable = true;
  ellie.udev.enable = true;
  ellie.users.enable = true;
  ellie.docker.enable = true;
  ellie.vm.enable = true;
  ellie.fcitx5.enable = true;

  personal.dslr-webcam = {
    enable = true;
    virtual-device-name = "a7iii";
    camera-udev-product = "54c/c34/200";
    ffmpeg-hwaccel = false;
  };

  #
  # Misc things, too small for their own module
  #

  time.timeZone = "Asia/Singapore";

  services.openssh.enable = true;

  programs.ssh.startAgent = true;

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.systemPackages = with pkgs; [ git vim ];

  environment.wordlist.enable = true;

  programs.steam.enable = true;

  services.nixseparatedebuginfod.enable = true;

  nix.settings.system-features = [ "gccarch-znver4" ];

  # To not upset Windows
  time.hardwareClockInLocalTime = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}
