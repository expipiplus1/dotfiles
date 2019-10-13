{ pkgs }:
rec {
  allowUnfree = true;
  allowBroken = true;
  android_sdk.accept_license = true;

  haskellPackageOverrides =
  let # A function to override the attributes passed to mkDerivation
      overrideAttrs = package: newAttrs: package.override (args: args // {
        mkDerivation = expr: args.mkDerivation (expr // newAttrs);
      });
  in with pkgs.haskell.lib; self: super: {
    vulkan = import (builtins.getEnv "HOME" + "/src/vulkan") {inherit pkgs;};
    # TODO: Check for GHC version
    brittany = (import (builtins.getEnv "HOME" + "/src/hie-nix") {}).brittany86;
  };

  packageOverrides = super: let pkgs = super.pkgs; in with pkgs; rec {

    tssh = writeTextFile {
      name = "tssh";
      text = ''
        #/usr/bin/env sh
        # ${pkgs.openssh}/bin/ssh "$@" -t -- tmux new-session -A -s main
        ${pkgs.mosh}/bin/mosh --server=.nix-profile/bin/mosh-server "$@" -- .nix-profile/bin/tmux attach
      '';
      executable = true;
      destination = "/bin/tssh";
    };

    upfind = import (pkgs.fetchFromGitHub {
      owner = "expipiplus1";
      repo = "upfind";
      rev = "e4514757b8a66cbf778bb03365b14e8bab2001b1";
      sha256 = "0mrzxibaxjvvpfvg8aszbn8jyld4bq47lnva2dc4mr2x6rhkr5jd";
    }) {inherit pkgs;};

    #
    # Some useful haskell tools
    #

    haskell-env = buildEnv {
      name = "haskell-env";
      paths = [
        cabal-install
      ] ++
      (ghc8Packages (haskell.packages.ghc865.override{overrides = haskellPackageOverrides;})) ++
      [ (import (builtins.getEnv "HOME" + "/src/hie-nix") {}).hie86
      ];
    };


    vim-env = buildEnv {
      name = "vim-env";
      paths = [
        neovim
        powerline-fonts
        xsel
      ];
    };
  };
}


