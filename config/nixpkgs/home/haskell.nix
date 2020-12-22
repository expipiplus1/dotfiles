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
    pkgs.docServer
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
    (self: super: {
      haskell = super.haskell // {
        packageOverrides = (with self.haskell.lib;
          (self: super: rec {
            upfind = import (pkgs.fetchFromGitHub {
              owner = "expipiplus1";
              repo = "upfind";
              rev = "cb451254f5b112f839aa36e5b6fd83b60cf9b9ae";
              sha256 = "15g5nvs6azgb2fkdna1dxbyiabx9n63if0wcbdvs91hjafhzjaqa";
            }) { };

            brittany = doJailbreak (dontCheck (overrideSrc super.brittany {
              version = "2020-12-15";
              src = pkgs.fetchFromGitHub {
                owner = "lspitzner";
                repo = "brittany";
                rev = "b1bfef5b8a96d0d114cc90c8ce38b8209d871348";
                sha256 = "1plj9f1yrd895zsz5iifk15dcxvscyyqdnikqxmcgkl5jryb4c6g";
              };
            }));

            # update-nix-fetchgit = import /home/j/projects/update-nix-fetchgit {
            #   inherit pkgs;
            #   forShell = false;
            # };

            # Fixes for HLS
            apply-refact = dontCheck super.apply-refact;
            # A patch to add heaps of default (safe) extensions
            ghc-exactprint = dontCheck (appendPatch super.ghc-exactprint
              ../../../patches/exactprint-exts.patch);
            ghcide = appendPatch super.ghcide ../../../patches/ghcide-682.patch;
          }));
      };

      upfind =
        pkgs.haskell.lib.justStaticExecutables self.haskellPackages.upfind;

      nix-linter = pkgs.haskell.lib.appendPatches super.nix-linter [
        ../../../patches/linter-unused.patch
        ../../../patches/linter-unused-pos.patch
      ];

      haskell-language-server = super.haskell-language-server.override {
        supportedGhcVersions = [ "884" "8102" ];
      };

      docServer = self.writeShellScriptBin "doc-server" ''
        dir=''${1:-.}
        if [ -f package.yaml ]; then
          echo package.yaml |
            ${pkgs.entr}/bin/entr -r -- \
              sh -c "hpack && cached-nix-shell $dir --keep XDG_DATA_DIRS --run 'hoogle server --local'"
        else
          echo *.cabal |
            ${pkgs.entr}/bin/entr -r -- \
              sh -c "cached-nix-shell $dir --keep XDG_DATA_DIRS --run 'hoogle server --local'"
        fi
      '';
    })
  ];
}
