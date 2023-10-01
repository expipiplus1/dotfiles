{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  nix.settings.system-features =
    [ "benchmark" "big-parallel" "kvm" "nixos-test" ];

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
}
