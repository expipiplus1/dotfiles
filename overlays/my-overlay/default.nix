{ ... }:

self: super: {
  haskell = super.haskell // {
    packageOverrides = (with self.haskell.lib;
      (hself: hsuper: {
        upfind = import (self.fetchFromGitHub {
          owner = "expipiplus1";
          repo = "upfind";
          rev = "cb451254f5b112f839aa36e5b6fd83b60cf9b9ae";
          sha256 = "15g5nvs6azgb2fkdna1dxbyiabx9n63if0wcbdvs91hjafhzjaqa";
        }) { pkgs = self; };
      }));
  };

  upfind =
    self.haskell.lib.compose.justStaticExecutables self.haskellPackages.upfind;

  tssh = self.writeTextFile {
    name = "tssh";
    text = ''
      #/usr/bin/env sh
      ${self.mosh}/bin/mosh --server=.nix-profile/bin/mosh-server "$@" -- .nix-profile/bin/tmux attach
    '';
    executable = true;
    destination = "/bin/tssh";
  };
}
