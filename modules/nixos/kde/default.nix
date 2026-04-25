{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "kde" {
  services = {
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    # xserver.displayManager.gdm.enable = true;

    # xserver.desktopManager.plasma5.enable = true;
    # displayManager.defaultSession = "plasmawayland";
    desktopManager.plasma6.enable = true;
    displayManager.defaultSession = "plasma";
  };

  programs.kdeconnect.enable = true;

  # KDE Connect uses mDNS/DNS-SD for device discovery; avahi provides the
  # multicast responder and ensures the kernel has a route for 224.0.0.251.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    gwenview
    okular
    oxygen
    khelpcenter
    konsole
    plasma-browser-integration
    print-manager
  ];

  environment.systemPackages = with pkgs; [ kdePackages.kdeplasma-addons ];

  programs.dconf.enable = true;

  environment = {
    etc."xdg/baloofilerc".source = (pkgs.formats.ini { }).generate "baloorc" {
      "Basic Settings" = { "Indexing-Enabled" = false; };
    };
  };
}
