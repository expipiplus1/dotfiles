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

    neovim-unconfigured = super.neovim;
    neovim-rtp = (import ./vim.nix {inherit pkgs neovim-unconfigured;}).rtpFile;
    neovim-rtp-cygwin = (import ./vim.nix {inherit pkgs neovim-unconfigured; cygwin = true;}).rtpFile;
    neovim = stdenv.mkDerivation {
      name = "neovim-configured";

      nativeBuildInputs = [ makeWrapper ];

      buildCommand = ''
        mkdir -p $out/bin
        for item in ${neovim-unconfigured}/bin/*; do
          ln -s $item $out/bin/
        done
        ln -s $out/bin/nvim $out/bin/vim
        wrapProgram $out/bin/nvim \
          --add-flags "--cmd 'source ${neovim-rtp}'" \
          --prefix PATH : \
          ${lib.makeBinPath [lessWrappedClang clang-tools]};

      '';
    };

    # Clang suitable for vim checking
    lessWrappedClang = clang.override {
      # Fixes http://lists.llvm.org/pipermail/cfe-users/2017-March/001112.html
      extraBuildCommands = ''
        sed -i 's|-B[^ ]*||g' $out/nix-support/libc-cflags
        sed -i 's|-B[^ ]*||g' $out/nix-support/cc-cflags
        sed -i 2d $out/nix-support/add-flags.sh
        substituteInPlace $out/bin/clang \
          --replace "source $out/nix-support/add-hardening.sh" "" \
          --replace "dontLink=0" "dontLink=1"
      '';
    };

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

    ghc8Packages = hp: with hp; [
      apply-refact
      # hdevtools
      ghcid
      hindent
      hlint
      pretty-show
      stylish-haskell
      cabal2nix
      # HaRe
      brittany
      upfind
      nix-diff
      hpack
    ];

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


