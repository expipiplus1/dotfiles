{ config, pkgs, ... }:

{
  imports = [ ./home/zsh.nix ./home/git.nix ./home/tmux.nix ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  news.display = "silent";
}
