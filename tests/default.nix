{ pkgs ? import <nixpkgs> { }, capture-golden ? false }:

with pkgs.lib;

let
  home-test = import ./home-test.nix { inherit pkgs capture-golden; };
  tests = [
    "vim-hls-error"
    "vim-complete-docs"
    "vim-diagnostic-list"
    "vim-format-function"
  ];

in genAttrs tests (name: import (./. + "/${name}.nix") home-test)
