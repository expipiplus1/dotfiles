{ pkgs, ... }: {
  nix.settings.system-features =
    [ "benchmark" "big-parallel" "kvm" "nixos-test" ];

  nix = {
    extraOptions = ''
      secret-key-files = /etc/nix/private-key
      experimental-features = nix-command flakes
    '';
  };

  system.autoUpgrade.randomizedDelaySec = "45min";
}
