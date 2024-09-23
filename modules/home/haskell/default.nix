{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "haskell" (let
  hindentOps = [
    # "-XBangPatterns"
    # "-XBinaryLiterals"
    # "-XBlockArguments"
    # "-XDataKinds"
    # "-XDeriveDataTypeable"
    # "-XDeriveFoldable"
    # "-XDeriveFunctor"
    # "-XDeriveGeneric"
    # "-XDeriveTraversable"
    # "-XDerivingStrategies"
    # "-XDisambiguateRecordFields"
    # "-XEmptyCase"
    # "-XExplicitForAll"
    # "-XExplicitNamespaces"
    # "-XFlexibleContexts"
    # "-XFlexibleInstances"
    # "-XFunctionalDependencies"
    # "-XGADTs"
    # "-XImplicitParams"
    # "-XImportQualifiedPost"
    # "-XInstanceSigs"
    # "-XKindSignatures"
    # "-XLambdaCase"
    # "-XMagicHash"
    # "-XMultiParamTypeClasses"
    # "-XMultiWayIf"
    # "-XOverloadedStrings"
    # "-XParallelListComp"
    # "-XPartialTypeSignatures"
    # "-XPatternGuards"
    # "-XPatternSynonyms"
    # "-XPolyKinds"
    # "-XQuasiQuotes"
    # "-XRankNTypes"
    # "-XRecordWildCards"
    # "-XRecursiveDo"
    # "-XRoleAnnotations"
    # "-XScopedTypeVariables"
    # "-XStandaloneDeriving"
    # "-XTemplateHaskell"
    # "-XTupleSections"
    # "-XTypeApplications"
    # "-XTypeFamilies"
    # "-XTypeFamilyDependencies"
    # "-XTypeOperators"
    # "-XViewPatterns"
  ];
  notHindentOpts = [
    # "-XDuplicateRecordFields" "-XNumDecimals"
  ];
  ghcOpts = hindentOps ++ notHindentOpts;
in {
  home.packages = with pkgs.haskellPackages; [
    pkgs.upfind
    pkgs.update-nix-fetchgit
    pkgs.cachix
    pkgs.nixfmt-classic
    cabal-fmt
    ghcid
    pkgs.hlint
    pretty-show
    cabal2nix
    fourmolu
    nix-diff
    hpack
    cabal-install
    weeder
    pkgs.docServer
  ];

  xdg.configFile."brittany/config.yaml".source = pkgs.writeText "config.yaml"
    (builtins.toJSON {
      conf_errorHandling = { econf_Werror = false; };
      conf_preprocessor = { ppconf_CPPMode = "CPPModeNowarn"; };
      conf_forward = { options_ghc = ghcOpts; };
    });

  xdg.configFile."fourmolu.yaml".source = pkgs.writeText "fourmolu.yaml"
    (builtins.toJSON {
      indentation = 2;
      column-limit = 100;
      function-arrows = "leading";
      comma-style = "leading";
      import-export-style = "leading";
      indent-wheres =
        false; # 'false' means save space by only half-indenting the 'where' keyword
      record-brace-space = false; # rec {x = 1} vs. rec{x = 1}
      haddock-style = "single-line"; # '--' vs. '{-'
      let-style = "auto";
      in-style = "right-align";
      single-constraint-parens = "auto";
      respectful = true; # don't be too opinionated about newlines etc.
    });

  home.file.".ghci".source = pkgs.writeText "ghci" ''
    :set prompt "\SOH\ESC[34m\STXλ>\SOH\ESC[m\STX "
    :set prompt-cont "|> "
    ${pkgs.lib.concatMapStringsSep "\n" (s: ":set ${s}") ghcOpts}
    :def hoogle \s -> Prelude.pure Prelude.$ ":! hoogle search -cl --count=15 \"" Prelude.++ s Prelude.++ "\""
    :def doc \s -> Prelude.pure Prelude.$ ":! hoogle search -cl --info \"" Prelude.++ s Prelude.++ "\""
    :set -Wno-x-partial
    :script ${pkgs.srcOnly pkgs.haskellPackages.ghc-vis + "/ghci"}
  '';

  home.file.".haskeline".source = pkgs.writeText "haskeline" ''
    maxhistorysize: Just 999999
    editMode: Vi
    historyDuplicates: IgnoreConsecutive
  '';
})
