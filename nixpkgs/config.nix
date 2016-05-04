{ pkgs }:
{
  allowUnfree = true;
  allowBroken = true;

  haskellPackageOverrides = with pkgs.haskell.lib; self: super: {
    haskell-src-exts = pkgs.haskellPackages.callPackage /home/jophish/src/haskell-src-exts/default.nix {};
    hlint = pkgs.haskellPackages.callPackage /home/jophish/src/hlint/default.nix {};
    hindent = pkgs.haskellPackages.callPackage /home/jophish/src/hindent/default.nix {};
    iridium = self.callPackage /home/jophish/src/iridium/default.nix {};
    stylish-haskell = self.callPackage /home/jophish/src/stylish-haskell/default.nix {};
    ghc-mod = self.callPackage /home/jophish/src/ghc-mod/default.nix {};
    stylish-haskell = self.callPackage /home/jophish/src/stylish-haskell/default.nix {};
    git-vogue = self.callPackage /home/jophish/src/git-vogue/default.nix {};
  };

  packageOverrides = super: let pkgs = super.pkgs; in with pkgs; rec {

    #
    # Irssi with a bunch of perl packages my config needs
    #
    irssi = lib.overrideDerivation super.irssi (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++
                    [ aspell
                      perlPackages.TextAspell
                      perlPackages.TextCharWidth
                      perlPackages.CryptX
                      perlPackages.JSONMaybeXS
                      makeWrapper
                    ];
      postInstall =
        ''
          wrapProgram "$out/bin/irssi" \
            --prefix PERL5LIB : ${perlPackages.TextAspell}/lib/perl5/site_perl/*/x86_64-linux-thread-multi \
            --prefix PERL5LIB : ${perlPackages.TextCharWidth}/lib/perl5/site_perl/*/x86_64-linux-thread-multi \
            --prefix PERL5LIB : ${perlPackages.CryptX}/lib/perl5/site_perl/*/x86_64-linux-thread-multi \
            --prefix PERL5LIB : ${perlPackages.JSONMaybeXS}/lib/perl5/site_perl/* \
            --prefix PERL5LIB : ${perlPackages.JSON}/lib/perl5/site_perl/*
        '';
    });

    #
    # To use 256 colors and a 16-palette with non-bright colors we need latest tmux and "-2"
    #
    tmux = lib.overrideDerivation super.tmux (oldAttrs: {
      src = fetchgit { url = "https://github.com/tmux/tmux";
                       rev = "c14fb5b633e63cc5f20d1f67fe071e4d4404e48e";
                       sha256 = "1rm61yhhzb01348qx26545k98cqdvxq27z8qfwcbyrpxjifn8hxp";
                     };
      buildInputs = oldAttrs.buildInputs ++ [ automake autoconf makeWrapper ];
      preConfigurePhases = [ "./autogen.sh" ];
      installPhase = ''
        mkdir $out
        make install
        wrapProgram $out/bin/tmux --add-flags "-2"
      '';
    });

    moc = lib.overrideDerivation super.moc (attrs: {
       buildInputs = attrs.buildInputs ++ (with pkgs; [ libsamplerate taglib libmpcdec wavpack faad2 curl file ]); # +librcc +libmagic -libmpc
    onfigureFlags = "--with-rcc --without-oss --with-alsa --with-jack --with-aac --with-mp3 --with-musepack --with-vorbis --with-flac --with-wavpack --with-sndfile --with-modplug --with-ffmpeg --with-speex --with-timidity --with-samplerate --with-curl --with-sidplay2 --with-magic --disable-cache --disable-debug";
     });

    # neovim = lib.overrideDerivation super.neovim (oldAttrs: {
    #   src = fetchFromGitHub {
    #     sha256 = "1sdz8k9nmc904xd0sli2z9cnbqdrk3pg5xnm6d8b24l5k4ljs6n1";
    #     rev = "0bbab3f5b9d43365b2916320aa55d69dc40d6036";
    #     repo = "neovim";
    #     owner = "expipiplus1"; };
    # });

    devEnv = with pkgs; buildEnv {
      name = "dev-env";
      paths = [
        git
      ];
    };

    cabalPackages = hp: with hp; [
      ghc-mod
      hdevtools
      hlint
      apply-refact
      hindent
      pretty-show
      shake
      stylish-haskell
      iridium
      git-vogue
      packunused
    ];

    haskell-env = with pkgs; buildEnv {
      name = "haskell-env";
      paths = [
        (pkgs.haskellPackages.ghcWithPackages cabalPackages)
        stack
        cabal-install
        cabal2nix
      ];
    };

    nixEnv = with pkgs; buildEnv {
      name = "nix-env";
      paths = [
        nox
        nix-prefetch-scripts
      ];
    };

    vimEnv = with pkgs; buildEnv {
      name = "vim-env";
      paths = [
        (neovim.override {vimAlias = true; extraPython3Packages = [(python3Packages.libclang-py3.override {src="/home/jophish/src/./././libclang-py3-0.3/";})];})
        powerline-fonts
        xsel
      ];
    };

    shellEnv = with pkgs; buildEnv {
      name = "shell-env";
      paths = [
        bashCompletion
        curl
        htop
        irssi
        silver-searcher
        sl
        tmux
      ];
    };
  };
}


