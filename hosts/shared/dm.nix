{ config, pkgs, ... }:

{
  imports = [
    ./dm/fonts.nix
  ];

  # Uncomment to use vulkan beta
  hardware.nvidia.package =
    config.boot.kernelPackages.nvidiaPackages.production;

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    extraLayouts.fc660c = with pkgs; {
      description = "My layout for the Leopold FC660C keyboard";
      languages = [ "eng" ];
      typesFile = ./dm/xkb-nixos/types/local;
      symbolsFile = ./dm/xkb-nixos/symbols/local;
    };
    layout = "fc660c";

    # To set types
    # displayManager.sessionCommands = ''
    #   sh -c 'sleep 5 && setxkbmap -verbose 10 fc660c -types fc660c' &
    # '';

    displayManager.gdm = {
      enable = true;
      wayland = false;
    };
    desktopManager.gnome.enable = true;
  };

  console.useXkbConfig = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  # Spotify nonsense
  # hardware.pulseaudio.daemon.config = { "enable-deferred-volume" = "no"; };
}

