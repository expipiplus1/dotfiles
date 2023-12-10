{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "desktop" {
  ellie.dm.enable = true;
  ellie.kde.enable = true;
  ellie.udev.enable = true;
  ellie.users.enable = true;
  ellie.fcitx5.enable = true;

  #
  # Misc things, too small for their own module
  #

  time.timeZone = "Asia/Singapore";

  services.openssh.enable = true;

  programs.ssh.startAgent = true;

  environment.systemPackages = with pkgs; [ git vim ];

  environment.wordlist.enable = true;

  programs.steam.enable = true;

  services.nixseparatedebuginfod.enable = true;

  # To not upset Windows
  time.hardwareClockInLocalTime = true;
}

