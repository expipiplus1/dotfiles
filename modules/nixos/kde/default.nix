{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "kde" {
  services.xserver = {
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    displayManager.defaultSession = "plasmawayland";
  };

  programs.kdeconnect.enable = true;

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    gwenview
    okular
    oxygen
    khelpcenter
    konsole
    plasma-browser-integration
    print-manager
  ];

  environment.systemPackages = with pkgs; [ kdeplasma-addons ];

  programs.dconf.enable = true;

  environment = {
    etc."xdg/baloofilerc".source = (pkgs.formats.ini { }).generate "baloorc" {
      "Basic Settings" = { "Indexing-Enabled" = false; };
    };
  };
}

