{ config, pkgs, ... }:

let
  ghcOpts = [
    "-XBangPatterns"
    "-XBinaryLiterals"
    "-XDataKinds"
    "-XDeriveDataTypeable"
    "-XDeriveFoldable"
    "-XDeriveFunctor"
    "-XDeriveGeneric"
    "-XDeriveTraversable"
    "-XDisambiguateRecordFields"
    "-XDuplicateRecordFields"
    "-XEmptyCase"
    "-XExplicitForAll"
    "-XFlexibleContexts"
    "-XFlexibleInstances"
    "-XFunctionalDependencies"
    "-XGADTs"
    "-XImplicitParams"
    "-XInstanceSigs"
    "-XKindSignatures"
    "-XLambdaCase"
    "-XMagicHash"
    "-XMonadComprehensions"
    "-XMultiParamTypeClasses"
    "-XMultiWayIf"
    "-XNumDecimals"
    "-XOverloadedStrings"
    "-XParallelListComp"
    "-XPartialTypeSignatures"
    "-XPatternGuards"
    "-XPatternSynonyms"
    "-XPolyKinds"
    "-XQuasiQuotes"
    "-XRankNTypes"
    "-XRecordWildCards"
    "-XRecursiveDo"
    "-XScopedTypeVariables"
    "-XStandaloneDeriving"
    "-XTemplateHaskell"
    "-XTupleSections"
    "-XTypeApplications"
    "-XTypeFamilies"
    "-XTypeOperators"
    "-XViewPatterns"
  ];

in {
  home.packages = with pkgs.haskellPackages;
    [
      pkgs.upfind
      pkgs.update-nix-fetchgit
      pkgs.cachix
      pkgs.nixfmt
      apply-refact
      ghcid
      hindent
      hlint
      pretty-show
      cabal2nix
      brittany
      nix-diff
      hpack
      cabal-install
    ] ++ [
      ((import (pkgs.fetchFromGitHub {
        owner = "Infinisil";
        repo = "all-hies";
        rev = "92148680060ed68f24738128d8489f4f9387d2ff";
        sha256 = "1yb75f8p09dp4yx5d3w3wvdiflaav9a5202xz9whigk2p9ndwbp5";
      }) { }).unstableFallback.selection {
        selector = p: { inherit (p) ghc865 ghc882; };
      })
    ];

  xdg.configFile."brittany/config.yaml".source = pkgs.writeText "config.yaml"
    (builtins.toJSON { conf_forward = { options_ghc = ghcOpts; }; });

  home.file.".ghci".source = pkgs.writeText "ghci" ''
    :set prompt "\SOH\ESC[34m\STXλ>\SOH\ESC[m\STX "
    ${pkgs.lib.concatMapStringsSep "\n" (s: ":set ${s}") ghcOpts}
    import qualified Prelude as P
    :def hoogle \s -> P.pure P.$ ":! hoogle search -cl --count=15 \"" P.++ s P.++ "\""
    :def doc \s -> P.pure P.$ ":! hoogle search -cl --info \"" P.++ s P.++ "\""
    :def pretty \_ -> P.pure ("import Text.Show.Pretty (pPrint, ppShow)\n:set -interactive-print pPrint")
    :def no-pretty \_ -> P.pure (":set -interactive-print System.IO.print")
  '';

  nixpkgs.overlays = [
    (import ((builtins.fetchTarball {
      url =
        "https://github.com/dhess/dhess-lib-nix/archive/b351d482784b11829d1d31979ecd11d437038fc3.tar.gz";
      sha256 = "0b1v4jlbm1z11q9zq6h40sh72cwc0c194zk88bpdm8j4ill98hc3";
    }) + "/overlays/haskell/lib.nix"))
    (self: super: {
      haskellPackages = self.haskell.lib.properExtend super.haskellPackages
        (self: super: {
          vulkan =
            import (builtins.getEnv "HOME" + "/src/vulkan") { inherit pkgs; };
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
