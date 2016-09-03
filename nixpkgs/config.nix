{ pkgs }:
rec {
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
    irssi = lib.overrideDerivation super.irssi (oldAttrs: rec {
      # It's an older code, but it checks out.
      version = "0.8.17";
      name = "irssi-${version}";
      src = fetchurl {
        urls = [ "https://distfiles.macports.org/irssi/${name}.tar.bz2"
                 "http://irssi.org/files/${name}.tar.bz2"
               ];
        sha256 = "01v82q2pfiimx6lh271kdvgp8hl4pahc3srg04fqzxgdsb5015iw";
      };

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

    tex = texlive.combine{
      inherit (texlive) 
              amsmath 
              babel
              booktabs 
              cm-super 
              ec 
              euenc
              etoolbox
              fontspec
              greek-inputenc
              lm 
              mathspec
              scheme-basic 
              xetex 
              xetex-def
              xkeyval
              xunicode
              zapfding
              collection-fontsrecommended
              collection-fontsextra
              ;
    };

    xc3sprog = lib.overrideDerivation super.xc3sprog (attrs: rec {
      version = "786"; # latest @ 2016-06-24
      name = "xc3sprog-${version}";

      src = fetchsvn rec {
        url = "https://svn.code.sf.net/p/xc3sprog/code/trunk";
        sha256 = "0p2dbd1ll263jjrmbb4543bhm0v52c17jh5a9kvql74i41jns4sq";
        rev = "${version}";
      };
    });

    neovim-noalias = lib.overrideDerivation super.neovim (attrs: rec {
      version = "v0.1.5";
      src = fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "006f9c0c9c96a406b610b9b76ff58b88f70ed674";
        sha256 = "19d0dr2ngvy1p6xxds28iqhz7z1p98mbm9yf4jyamg54wdck6mh3";
      };
    });

    neovim = stdenv.mkDerivation {
      name = "neovim-${neovim-noalias.version}-configured";
      inherit (neovim-noalias) version;

      nativeBuildInputs = [ makeWrapper ];

      buildCommand = ''
        mkdir -p $out/bin
        for item in ${neovim-noalias}/bin/*; do
          ln -s $item $out/bin/
        done
        ln -s $out/bin/nvim $out/bin/vim
      '';
    };

    #
    # Some useful haskell tools
    #

    cabalPackages = hp: with hp; [
      apply-refact_0_2_0_0
      ghc-mod
      hdevtools
      ghcid
      hackage-diff
      HaRe_0_8_2_3
      hindent
      hlint
      intero
      iridium
      packunused
      pointfree
      pretty-show
      shake
      stylish-haskell
    ];

    ghc8Packages = hp: with hp; [
    ];

    haskell-env = buildEnv {
      name = "haskell-env";
      paths = [
        cabal-install
        cabal2nix
      ] ++
      (cabalPackages (haskell.packages.ghc7103.override{overrides = haskellPackageOverrides;})) ++
      (ghc8Packages haskell.packages.ghc801);
    };


    vim-env = buildEnv {
      name = "vim-env";
      paths = [
        neovim
        powerline-fonts
        xsel
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
        zsh
      ];
    };

    pandocEnv = buildEnv {
      name = "pandoc-env";
      paths = [
        (import <nixpkgs> {}).pandoc
        pdftk
        tex
      ];
    };
  };
}


