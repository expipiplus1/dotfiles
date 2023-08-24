{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  nixpkgs.overlays = [
    (self: super: {
      direnv = super.direnv.overrideAttrs (old: {
        patches = old.patches or [ ] ++ [ ../patches/quiet-direnv.patch ];
      });
    })
  ];
}
