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
            --prefix PERL5LIB : ${perlPackages.TextAspell}/${perl.libPrefix}/*/* \
            --prefix PERL5LIB : ${perlPackages.TextCharWidth}/${perl.libPrefix}/*/* \
            --prefix PERL5LIB : ${perlPackages.CryptX}/${perl.libPrefix}/*/* \
            --prefix PERL5LIB : ${perlPackages.JSONMaybeXS}/${perl.libPrefix}/* \
            --prefix PERL5LIB : ${perlPackages.JSON}/${perl.libPrefix}/*
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

    #
    # MOC with configure flags enabling most things
    #
    moc = lib.overrideDerivation super.moc (attrs: {
       buildInputs = attrs.buildInputs ++ 
                    [ libsamplerate taglib libmpcdec wavpack faad2 curl file ]; 
       configureFlags = ''--with-rcc --with-oss --with-alsa --with-jack
         --with-aac --with-mp3 --with-musepack --with-vorbis --with-flac
         --with-wavpack --with-sndfile --with-modplug --with-ffmpeg
         --with-speex --with-timidity --with-samplerate --with-curl
         --with-sidplay2 --with-magic --disable-cache --disable-debug'';
     });

    #
    # NeoVim and it's dependencies
    #
    vim-env = buildEnv {
      name = "vim-env";
      paths = [
        (neovim.override {vimAlias = true;})
        powerline-fonts
        xsel
      ];
    };

    #
    # Some useful haskell tools
    #

    cabalPackages = hp: with hp; [
      HaRe
      apply-refact
      ghc-mod
      git-vogue
      hindent
      hlint
      iridium
      packunused
      pointfree
      pretty-show
      shake
      stylish-haskell
    ];

    haskell-env = buildEnv {
      name = "haskell-env";
      paths = [
        (cabalPackages haskellPackages)
        stack
        cabal-install
        cabal2nix
      ];
    };


    #
    # Everything I want
    #

    dev-env = buildEnv {
      name = "dev-env";
      paths = [
        curl
        git
        haskell-env
        htop
        irssi
        nox
        silver-searcher
        tmux
        vim-env
        zsh
      ];
    };
  };
}


