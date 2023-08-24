{ pkgs, ... }:

let
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
    pkgs.nixfmt
    cabal-fmt
    ghcid
    pkgs.hlint
    pretty-show
    cabal2nix
    (pkgs.writeShellScriptBin "fourmolu" ''
      exec ${pkgs.haskell.packages.ghc94.fourmolu_0_13_1_0}/bin/fourmolu ${
        pkgs.lib.concatMapStringsSep " " (s: "--ghc-opt ${s}") ghcOpts
      } "$@"
    '')
    nix-diff
    hpack
    cabal-install
    pkgs.haskell-language-server
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
      function-arrows = "leading";
      comma-style = "leading";
      import-export-style = "leading";
      indent-wheres =
        false; # 'false' means save space by only half-indenting the 'where' keyword
      record-brace-space = false; # rec {x = 1} vs. rec{x = 1}
      haddock-style = "single-line"; # '--' vs. '{-'
      respectful = true; # don't be too opinionated about newlines etc.
      in-style = "right-align";
      let-style = "auto";
    });

  home.file.".ghci".source = pkgs.writeText "ghci" ''
    :set prompt "\SOH\ESC[34m\STXλ>\SOH\ESC[m\STX "
    :set prompt-cont "|> "
    ${pkgs.lib.concatMapStringsSep "\n" (s: ":set ${s}") ghcOpts}
    :def hoogle \s -> Prelude.pure Prelude.$ ":! hoogle search -cl --count=15 \"" Prelude.++ s Prelude.++ "\""
    :def doc \s -> Prelude.pure Prelude.$ ":! hoogle search -cl --info \"" Prelude.++ s Prelude.++ "\""
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
            }) { inherit pkgs; };

            # brittany = doJailbreak (dontCheck (overrideSrc super.brittany {
            #   version = "2021-02-26";
            #   src = pkgs.fetchFromGitHub {
            #     owner = "lspitzner";
            #     repo = "brittany";
            #     rev = "4d064db674203626fe5011d10874fcbc335ec9b1"; # master
            #     sha256 = "1sanc1n72s4jknnx6snryvynrccp1hvzlqfpfb3fy5gn6aapfwzi";
            #   };
            # }));

            fourmolu-ellie = overrideSrc super.fourmolu {
              version = "2021-06-13";
              src = pkgs.fetchFromGitHub {
                owner = "expipiplus1";
                repo = "fourmolu";
                rev =
                  "35dbface79d722952163e0c862951cbd6ca175fc"; # joe-align-leading
                sha256 = "1p9bmzvy7g14g348s1f3ymfy0c5k4dxr9jqw180jix0ichrg9r7h";
              };
            };

            nix-diff = doJailbreak super.nix-diff;
          }));
      };

      upfind =
        pkgs.haskell.lib.justStaticExecutables self.haskellPackages.upfind;

      haskell-language-server = super.haskell-language-server.override {
        supportedGhcVersions = [ "92" "94" ];
      };

      docServer = self.writeShellScriptBin "doc-server" ''
        shopt -s nullglob
        dir=''${1:-.}
        if [ -f flake.nix ]; then
          printf '%s\n' flake.nix *.cabal *.package.yaml |
            ${pkgs.entr}/bin/entr -r -- \
              sh -c "direnv reload && direnv exec . hoogle server --local"
        elif [ -f package.yaml ]; then
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
