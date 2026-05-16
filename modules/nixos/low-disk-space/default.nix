{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "low-disk-space" {
  nix.settings.auto-optimise-store = true;
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.extraOptions = ''
    min-free = ${toString (512 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';

  # Remove old system generations, keeping the most recent 2
  systemd.services.cleanup-system-generations = {
    description = "Remove old NixOS system generations";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.nix ];
    script = ''
      nix-env --delete-generations +2 -p /nix/var/nix/profiles/system
    '';
  };
  systemd.timers.cleanup-system-generations = {
    description = "Remove old NixOS system generations daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
