{ config, pkgs, ... }:

{
  home.packages = with pkgs.haskellPackages; [
    pkgs.upfind
    pkgs.update-nix-fetchgit
  ] ++ map pkgs.haskell.lib.justStaticExecutables [
    apply-refact
    ghcid
    hindent
    hlint
    pretty-show
    stylish-haskell
    cabal2nix
    brittany
    nix-diff
    hpack
  ] ++ [
    ((import (builtins.fetchTarball
      "https://github.com/infinisil/all-hies/tarball/master")
      { }).bios.selection { selector = p: { inherit (p) ghc865; }; })
    (import (builtins.fetchTarball
      "https://github.com/hercules-ci/ghcide-nix/tarball/master")
      { }).ghcide-ghc865
  ];

  nixpkgs.overlays = [
    (import ((builtins.fetchTarball {
      url =
        "https://github.com/dhess/dhess-lib-nix/archive/b351d482784b11829d1d31979ecd11d437038fc3.tar.gz";
      sha256 = "0b1v4jlbm1z11q9zq6h40sh72cwc0c194zk88bpdm8j4ill98hc3";
    }) + "/overlays/haskell/lib.nix"))
    (self: super: {
      haskellPackages = self.haskell.lib.properExtend super.haskellPackages
        (self: super: {
          vulkan = import (builtins.getEnv "HOME" + "/src/vulkan") {inherit pkgs;};
          upfind = import (pkgs.fetchFromGitHub {
            owner = "expipiplus1";
            repo = "upfind";
            rev = "cb451254f5b112f839aa36e5b6fd83b60cf9b9ae";
            sha256 = "15g5nvs6azgb2fkdna1dxbyiabx9n63if0wcbdvs91hjafhzjaqa";
          }) { };
          update-nix-fetchgit = import (pkgs.fetchFromGitHub {
            owner = "expipiplus1";
            repo = "update-nix-fetchgit";
            rev = "38d8fdc44833e3dc036ab9b59aedae2e673d6c33";
            sha256 = "12y32zw6k2wlr3s7vqlci5akb8szpy2xk44pavapcgsxfrp4bb2q";
          }) { };
        });

      upfind =
        self.haskell.lib.justStaticExecutables self.haskellPackages.upfind;
      update-nix-fetchgit = self.haskell.lib.justStaticExecutables
        self.haskellPackages.update-nix-fetchgit;
    })
  ];
}
