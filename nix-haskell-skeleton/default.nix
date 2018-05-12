{ pkgs ? import <nixpkgs> {}, compiler ? "ghc822" }:

# Strip out the irrelevant parts of the source
let src = with pkgs.lib;
          let p = n: (toString ./dist) == n;
          in cleanSourceWith {filter = (n: t: !p n); src = cleanSource ./.;};

    haskellPackages = pkgs.haskell.packages.${compiler}.override {
      overrides = self: super: {
      };
    };

    extraEnvPackages = [
    ];

    drv =
      haskellPackages.callCabal2nix "package_name" src {};

    envWithExtras = pkgs.lib.overrideDerivation drv.env (attrs: {
      buildInputs = attrs.buildInputs ++ extraEnvPackages;
    });

in
  drv // { env = envWithExtras; }
