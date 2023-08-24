{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      imagemagick = super.imagemagick.override { librsvg = null; };
    })
  ];
}
