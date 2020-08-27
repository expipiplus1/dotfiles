{ config, pkgs, ... }:

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

  refactor-unwrapped = import (pkgs.fetchFromGitHub {
    owner = "mpickering";
    repo = "apply-refact";
    rev = "f8ccb9338fdc7efe59ca31df12b3d1b10804221c";
    sha256 = "1hxn1ixad9qkmcjx55sk0pkyrly490h91bksc9ziqhqi0fvhrmw6";
  }) { inherit pkgs; };
  refactor = pkgs.symlinkJoin {
    name = "refactor";
    paths = [ refactor-unwrapped ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/refactor \
        --add-flags "${pkgs.lib.concatStringsSep " " ghcOpts}"
    '';
  };

in {
  home.packages = with pkgs.haskellPackages;
    [
      pkgs.upfind
      pkgs.update-nix-fetchgit
      pkgs.cachix
      pkgs.nixfmt
      ghcid
      (pkgs.symlinkJoin {
        name = "hindent";
        paths = [ hindent ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hindent \
            --add-flags "${pkgs.lib.concatStringsSep " " hindentOps}"
        '';
      })
      (pkgs.symlinkJoin {
        name = "hlint";
        paths = [ hlint ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hlint \
            --add-flags "${pkgs.lib.concatStringsSep " " ghcOpts}" \
            --add-flags "--with-refactor=${refactor}/bin/refactor"
        '';
      })
      pretty-show
      cabal2nix
      (pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.overrideSrc brittany {
        src = pkgs.fetchFromGitHub {
          owner = "lspitzner";
          repo = "brittany";
          rev = "5bf6d4a8591dda549ceac618a20146e6953a81ee";
          sha256 = "0gv57kj17r8x6h82rwabx84g2xqx5g351kr78rcfqqbw0335d9hl";
          # rev = "71aaab89689443269cee31c5741c5086e0cff885";
          # sha256 = "0kb789jqfd457l6ik0r1rvqlp5fs7i6w5n6m76rk4747byhn8dhr";
        };
      }))
      nix-diff
      hpack
      cabal-install
    ];

  xdg.configFile."brittany/config.yaml".source = pkgs.writeText "config.yaml"
    (builtins.toJSON { conf_forward = { options_ghc = ghcOpts; }; });

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
        "https://github.com/dhess/dhess-lib-nix/archive/b351d482784b11829d1d31979ecd11d437038fc3.tar.gz";
      sha256 = "0b1v4jlbm1z11q9zq6h40sh72cwc0c194zk88bpdm8j4ill98hc3";
    }) + "/overlays/haskell/lib.nix"))
    (self: super: {
      haskellPackages = self.haskell.lib.properExtend super.haskellPackages
        (self: super: {
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

      haskell-language-server = (import (pkgs.fetchFromGitHub {
        owner = "expipiplus1";
        repo = "nixpkgs";
        rev = "aa0baffd24179e663e45f086fcf2a62a3109a8c5";
        sha256 = "0pbskvvw0nirqlsmpxfrvfblqnhfsm80bbqpsc0rc4fb5gh9d8n8";
      }) { inherit config; }).haskellPackages.haskell-language-server;
    })
  ];
}
