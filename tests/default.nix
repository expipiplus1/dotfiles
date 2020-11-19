{ capture-golden ? false }:

with (import <nixpkgs> { }).lib;

let
  home-test = import ./home-test.nix { inherit capture-golden; };
  tests = [ "vim-hls-error" "vim-complete-docs" "vim-diagnostic-list" ];

in genAttrs tests (name: import (./. + "/${name}.nix") home-test)
