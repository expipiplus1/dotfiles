{ pkgs, ... }: {
  nix.settings.system-features =
    [ "benchmark" "big-parallel" "kvm" "nixos-test" ];

  nix = {
    extraOptions = ''
      secret-key-files = /etc/nix/private-key
      experimental-features = nix-command flakes
      extra-deprecated-features = or-as-identifier
    '';
  };

  system.autoUpgrade.randomizedDelaySec = "45min";
}
