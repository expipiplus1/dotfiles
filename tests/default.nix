with (import <nixpkgs> { }).lib;

genAttrs [ "vim-hls-error" "vim-complete-docs" "vim-diagnostic-list" ]
(name: import (./. + "/${name}.nix"))
