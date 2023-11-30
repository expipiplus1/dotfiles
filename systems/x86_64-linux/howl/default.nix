{ config, lib, pkgs, ... }:

{
  wsl.enable = true;
  wsl.defaultUser = "e";

  networking.hostName = "howl";

  time.timeZone = "Asia/Singapore";

  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;

  # Keep programs alive after logout (for example, tmux)
  services.logind.killUserProcesses = false;

  ellie.users.enable = true;

  system.stateVersion = "23.05"; # Did you read the comment?
}
