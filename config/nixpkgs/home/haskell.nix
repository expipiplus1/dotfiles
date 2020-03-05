{ config, pkgs, ... }:

let
  hindentOps = [
    "-XBangPatterns"
    "-XBinaryLiterals"
    "-XDataKinds"
    "-XDeriveDataTypeable"
    "-XDeriveFoldable"
    "-XDeriveFunctor"
    "-XDeriveGeneric"
    "-XDeriveTraversable"
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
      (pkgs.haskell.lib.overrideSrc brittany {
        src = pkgs.fetchFromGitHub {
          owner = "lspitzner";
          repo = "brittany";
          rev = "4b673d1d9db70e3a0d01a6b3315618e30b887c78";
          sha256 = "0m74dryw1ijpc4m21cxf4yln77fqpfyh47nhhnipvlygi5rc6n1w";
        };
      })
      nix-diff
      hpack
      cabal-install
    ] ++ [
      ((import (pkgs.fetchFromGitHub {
        owner = "Infinisil";
        repo = "all-hies";
        rev = "329d740561641b2c2c6e261d5870a1dc4ab9cfdc";
        sha256 = "14w9hh1m1njk9p32j2y2blrsf61x4x2m3a46rq9n1qzb2yk6ywg0";
      }) { inherit pkgs; }).unstableFallback.selection {
        selector = p: { inherit (p) ghc882; };
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
