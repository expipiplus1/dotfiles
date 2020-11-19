{ pkgs, ... }:

let
  hindentOps = [
    "-XBangPatterns"
    "-XBinaryLiterals"
    "-XBlockArguments"
    "-XDataKinds"
    "-XDeriveDataTypeable"
    "-XDeriveFoldable"
    "-XDeriveFunctor"
    "-XDeriveGeneric"
    "-XDeriveTraversable"
    "-XDerivingStrategies"
    "-XDisambiguateRecordFields"
    "-XEmptyCase"
    "-XExplicitForAll"
    "-XExplicitNamespaces"
    "-XFlexibleContexts"
    "-XFlexibleInstances"
    "-XFunctionalDependencies"
    "-XGADTs"
    "-XImplicitParams"
    "-XInstanceSigs"
    "-XKindSignatures"
    "-XLambdaCase"
    "-XMagicHash"
    "-XMultiParamTypeClasses"
    "-XMultiWayIf"
    "-XOverloadedStrings"
    "-XParallelListComp"
    "-XPartialTypeSignatures"
    "-XPatternGuards"
    "-XPatternSynonyms"
    "-XPolyKinds"
    "-XQuasiQuotes"
    "-XRankNTypes"
    "-XRecordWildCards"
    "-XRoleAnnotations"
    "-XScopedTypeVariables"
    "-XStandaloneDeriving"
    "-XTemplateHaskell"
    "-XTupleSections"
    "-XTypeApplications"
    "-XTypeFamilies"
    "-XTypeFamilyDependencies"
    "-XTypeOperators"
    "-XViewPatterns"
  ];
  notHindentOpts =
    [ "-XDuplicateRecordFields" "-XMonadComprehensions" "-XNumDecimals" ];
  ghcOpts = hindentOps ++ notHindentOpts;
in {
  home.packages = with pkgs.haskellPackages; [
    pkgs.upfind
    pkgs.update-nix-fetchgit
    # pkgs.cachix
    pkgs.nixfmt
    ghcid
    pkgs.hlint
    pretty-show
    cabal2nix
    brittany
    nix-diff
    hpack
    cabal-install
    pkgs.haskell-language-server
    weeder
    nix-output-monitor
  ];

  xdg.configFile."brittany/config.yaml".source = pkgs.writeText "config.yaml"
    (builtins.toJSON {
      conf_errorHandling = { econf_Werror = false; };
      conf_preprocessor = { ppconf_CPPMode = "CPPModeNowarn"; };
      conf_forward = { options_ghc = ghcOpts; };
    });

  home.file.".ghci".source = pkgs.writeText "ghci" ''
    :set prompt "\SOH\ESC[34m\STXλ>\SOH\ESC[m\STX "
    :set prompt-cont "|> "
    ${pkgs.lib.concatMapStringsSep "\n" (s: ":set ${s}") ghcOpts}
    import qualified Prelude as P
    :def hoogle \s -> P.pure P.$ ":! hoogle search -cl --count=15 \"" P.++ s P.++ "\""
    :def doc \s -> P.pure P.$ ":! hoogle search -cl --info \"" P.++ s P.++ "\""
  '';

  home.file.".haskeline".source = pkgs.writeText "haskeline" ''
    maxhistorysize: Just 999999
    editMode: Vi
    historyDuplicates: IgnoreConsecutive
  '';

  nixpkgs.overlays = [
    (import ((builtins.fetchTarball {
      url =
        "https://github.com/dhess/dhess-lib-nix/archive/b351d482784b11829d1d31979ecd11d437038fc3.tar.gz"; # pin
      sha256 = "0b1v4jlbm1z11q9zq6h40sh72cwc0c194zk88bpdm8j4ill98hc3";
    }) + "/overlays/haskell/lib.nix"))
    (self: super:
      with self.haskell.lib; {
        haskellPackages = properExtend super.haskellPackages (self: super: {
          upfind = import (pkgs.fetchFromGitHub {
            owner = "expipiplus1";
            repo = "upfind";
            rev = "cb451254f5b112f839aa36e5b6fd83b60cf9b9ae";
            sha256 = "15g5nvs6azgb2fkdna1dxbyiabx9n63if0wcbdvs91hjafhzjaqa";
          }) { };

          brittany = doJailbreak (dontCheck (overrideSrc super.hls-brittany {
            version = "0.12.2.0";
            src = pkgs.fetchFromGitHub {
              owner = "expipiplus1";
              repo = "brittany";
              rev = "b80f77c36bda563665c616abbdb1eaaf35b1da1c"; # joe
              sha256 = "1ih2qd73and863yzn7r96vg89mlayq8rr91jql2w5mf9n17lkj4w";
            };
          }));
          hls-brittany = self.brittany;

          update-nix-fetchgit = import /home/j/projects/update-nix-fetchgit {
            inherit pkgs;
            forShell = false;
          };

          # Fixes for HLS
          apply-refact = dontCheck super.apply-refact;
          # A patch to add heaps of default (safe) extensions
          ghc-exactprint = dontCheck (appendPatch super.ghc-exactprint
            ../../../patches/exactprint-exts.patch);
          streamly = overrideSrc super.streamly {
            src = pkgs.fetchFromGitHub {
              owner = "composewell";
              repo = "streamly";
              rev = "f72dcaf4932b2fc24a10156507a980858e2c108d";
              sha256 = "123dqb8hiq04flff1rga3qb01rh2mpnb4aax6vx1gd472s5kvcc2";
            };
          };
        });

        upfind = justStaticExecutables self.haskellPackages.upfind;

        nix-linter = appendPatches super.nix-linter [
          ../../../patches/linter-unused.patch
          ../../../patches/linter-unused-pos.patch
          ../../../patches/linter-streamly-prelude.patch
        ];
      })
  ];
}
