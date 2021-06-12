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
    (pkgs.writeShellScriptBin "fourmolu" ''
      exec ${fourmolu}/bin/fourmolu ${
        pkgs.lib.concatMapStringsSep " " (s: "--ghc-opt ${s}") ghcOpts
      } "$@"
    '')
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

  xdg.configFile."fourmolu.yaml".source = pkgs.writeText "fourmolu.yaml"
    (builtins.toJSON {
      indentation = 2;
      comma-style = "leading"; # for lists, tuples etc. - can also be 'trailing'
      record-brace-space = false; # rec {x = 1} vs. rec{x = 1}
      indent-wheres =
        false; # 'false' means save space by only half-indenting the 'where' keyword
      diff-friendly-import-export = false; # 'false' uses Ormolu-style lists
      respectful = true; # don't be too opinionated about newlines etc.
      haddock-style = "single-line"; # '--' vs. '{-'
      newlines-between-decls =
        1; # number of newlines between top-level declarations
      align = true;
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
              version = "2021-02-26";
              src = pkgs.fetchFromGitHub {
                owner = "lspitzner";
                repo = "brittany";
                rev = "4d064db674203626fe5011d10874fcbc335ec9b1"; # master
                sha256 = "1sanc1n72s4jknnx6snryvynrccp1hvzlqfpfb3fy5gn6aapfwzi";
              };
            }));

            # update-nix-fetchgit = import /home/j/projects/update-nix-fetchgit {
            #   inherit pkgs;
            #   forShell = false;
            # };

            nix-diff = doJailbreak super.nix-diff;
          }));
      };

      upfind =
        pkgs.haskell.lib.justStaticExecutables self.haskellPackages.upfind;

      nix-linter = pkgs.haskell.lib.appendPatches super.nix-linter [
        ../../../patches/linter-unused.patch
        ../../../patches/linter-unused-pos.patch
      ];

      haskell-language-server = super.haskell-language-server.override {
        supportedGhcVersions = [ "8104" ];
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
