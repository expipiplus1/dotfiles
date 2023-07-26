{ config, pkgs, ... }:

{
  services.openssh.enable = true;

  programs.ssh.startAgent = true;
}

