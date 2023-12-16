{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "desktop" {
  ellie.dm.enable = true;
  ellie.kde.enable = true;
  ellie.bluetooth.enable = true;
  ellie.udev.enable = true;
  ellie.users.enable = true;
  ellie.fcitx5.enable = true;
  ellie.docker.enable = true;
  ellie.vm.enable = true;
  personal.dslr-webcam = {
    enable = true;
    virtual-device-name = "a7iii";
    camera-udev-product = "54c/c34/200";
    ffmpeg-hwaccel = false;
  };

  #
  # Misc things, too small for their own module
  #

  networking.networkmanager.enable = true;

  networking.useDHCP = lib.mkDefault true;

  time.timeZone = "Asia/Singapore";

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.openssh.enable = true;

  programs.ssh.startAgent = true;

  environment.systemPackages = with pkgs; [ git vim lm_sensors ntfs3g ];

  environment.wordlist.enable = true;

  programs.steam.enable = true;

  services.nixseparatedebuginfod.enable = true;

  # To not upset Windows
  time.hardwareClockInLocalTime = true;
}

