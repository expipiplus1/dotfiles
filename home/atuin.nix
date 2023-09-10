{ config, pkgs, lib, ... }: {
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      update_check = false;
      search_mode = "fuzzy";
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      atuin = super.atuin.overrideAttrs (old: {
        patches = old.patches or [ ] ++ [ ../patches/atuin-popup.patch ];
      });
    })
  ];
}
