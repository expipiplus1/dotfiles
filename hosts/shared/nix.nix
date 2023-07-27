{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  nix.settings.system-features =
    [ "gccarch-znver3" "benchmark" "big-parallel" "kvm" "nixos-test" ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      secret-key-files = /etc/nix/private-key
      experimental-features = nix-command flakes
    '';
  };

  system.autoUpgrade = {
    enable = false;
    randomizedDelaySec = "45min";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
