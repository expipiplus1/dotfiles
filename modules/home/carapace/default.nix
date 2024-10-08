{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "carapace" { programs.carapace.enable = true; }
