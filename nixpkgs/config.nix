{ pkgs }:
rec {
  allowUnfree = true;
  allowBroken = true;

  haskellPackageOverrides = with pkgs.haskell.lib; self: super: {
  };

  tex =
    let texliveWIP = pkgs.fetchFromGitHub{
          owner = "vcunat";
          repo = "nixpkgs";
          rev = "8481eca63c6196b38072aa43dc291ff222c84357";
          sha256 = "0qhx8kiflg7rm5xwnhh4nmb3vb55pnb9y0zk6b4p8qk0zkpc2i5z";
        };
    in with import texliveWIP {};
       texlive.combine{
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
                 siunitx
                 xetex
                 xetex-def
                 xkeyval
                 xunicode
                 zapfding
                 collection-fontsrecommended
                 collection-fontsextra
                 ;
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


    xc3sprog = lib.overrideDerivation super.xc3sprog (attrs: rec {
      version = "786"; # latest @ 2016-06-24
      name = "xc3sprog-${version}";

      src = fetchsvn rec {
        url = "https://svn.code.sf.net/p/xc3sprog/code/trunk";
        sha256 = "0p2dbd1ll263jjrmbb4543bhm0v52c17jh5a9kvql74i41jns4sq";
        rev = "${version}";
      };
    });

    neovim-unconfigured = super.neovim;
    neovim-rtp = (import ./vim.nix {inherit pkgs;}).rtpFile;
    neovim = stdenv.mkDerivation {
      name = "neovim-${neovim-unconfigured.version}-configured";
      inherit (neovim-unconfigured) version;

      nativeBuildInputs = [ makeWrapper ];

      buildCommand = ''
        mkdir -p $out/bin
        for item in ${neovim-unconfigured}/bin/*; do
          ln -s $item $out/bin/
        done
        ln -s $out/bin/nvim $out/bin/vim
        wrapProgram $out/bin/nvim --add-flags "--cmd 'source ${neovim-rtp}'"
      '';
    };


    #
    # Some useful haskell tools
    #

    ghc8Packages = hp: with hp; [
      apply-refact
      ghc-mod
      hdevtools
      ghcid
      hackage-diff
      # HaRe
      hindent
      hlint
      pointfree
      pretty-show
      shake
      stylish-haskell
    ];

    ghc7Packages = hp: with hp; [
      iridium
    ];

    haskell-env = buildEnv {
      name = "haskell-env";
      paths = [
        cabal-install
        haskell.packages.ghc801.cabal2nix
      ] ++
      (ghc8Packages (haskell.packages.ghc801.override{overrides = haskellPackageOverrides;})) ++
      (ghc7Packages (haskell.packages.ghc7103.override{overrides = haskellPackageOverrides;}));
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
        coreutils
        curl
        git
        haskell-env
        htop
        irssi
        nox
        silver-searcher
        tig
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


