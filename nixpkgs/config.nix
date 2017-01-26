{ pkgs }:
rec {
  allowUnfree = true;
  allowBroken = true;

  haskellPackageOverrides =
  let # A function to override the attributes passed to mkDerivation
      overrideAttrs = package: newAttrs: package.override (args: args // {
        mkDerivation = expr: args.mkDerivation (expr // newAttrs);
      });
  in with pkgs.haskell.lib; self: super: {
    ghc-exactprint = overrideAttrs super.ghc-exactprint {
      doCheck = false;
    };
    apply-refact = overrideAttrs super.apply-refact {
      jailbreak = true;
    };
    haskell-src-exts = super.haskell-src-exts_1_19_1;
    haskell-src-meta = overrideAttrs super.haskell-src-meta_0_7_0_1 {
      jailbreak = true;
    };
    hlint = super.hlint_1_9_39;
    stylish-haskell = overrideAttrs super.stylish-haskell_0_6_5_0 {
      jailbreak = true;
    };
    ghc-mod = overrideAttrs super.ghc-mod {
      jailbreak = true;
      editedCabalFile = null;
      revision = null;
      src = pkgs.fetchFromGitHub{
        owner = "expipiplus1";
        repo = "ghc-mod";
        rev = "666f47ca14f3f5ecdd4a95a36e493cc1deb565d2";
        sha256 = "0s390v07icjp800vjd5qzjhm9bdrr8kr1s2nc90glbd43lv582iv";
      };
    };
    HaRe = overrideAttrs super.HaRe {
      doCheck = false;
      editedCabalFile = null;
      revision = null;
      src = pkgs.fetchFromGitHub{
        owner = "expipiplus1";
        repo = "HaRe";
        rev = "acd29d035d7ffc6c51feb567f4449e29f3458602";
        sha256 = "08ihjck60b67hcd7p0c7mk7p4a084ziwi5jv8ly952vajiq66pcc";
      };
      libraryHaskellDepends = with self; [
        base Cabal cabal-helper containers directory filepath ghc
        ghc-exactprint ghc-mod ghc-paths ghc-prim ghc-syb-utils hslogger
        monad-control monoid-extras mtl old-time pretty rosezipper
        semigroups Strafunski-StrategyLib syb syz time transformers
        transformers-base
        attoparsec base-prelude case-insensitive conversion conversion-case-insensitive conversion-text foldl turtle
      ];
    };
    Strafunski-StrategyLib = overrideAttrs super.Strafunski-StrategyLib {
      jailbreak = true;
    };
    cabal-helper = overrideAttrs super.cabal-helper {
      jailbreak = true;
    };
    path-io = overrideAttrs super.path-io {
      jailbreak = true;
    };
    tasty-ant-xml = overrideAttrs super.tasty-ant-xml {
      jailbreak = true;
    };
    turtle = overrideAttrs super.turtle {
      jailbreak = true;
    };
    xmlhtml = overrideAttrs super.xmlhtml {
      jailbreak = true;
    };
  };

  tex = with pkgs;
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

      NIX_LDFLAGS = ncurses.ldflags;

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

    cmus = lib.overrideDerivation super.cmus (attrs: rec{
      src = fetchFromGitHub {
        owner = "cmus";
        repo = "cmus";
        rev = "ef65f69b3e44a79956c138c83dd64ef41e27f206";
        sha256 = "0hkwgpqzmi2979ksdjmdnw9fxyd6djsrcyhvj1gy7kpdjw4az4s9";
      };
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

    neovim-unconfigured = lib.overrideDerivation super.neovim (attrs: rec{
      src = fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "f2c6cc2d0932dc791054fe2acc799f0fea8109d9";
        sha256 = "0pwcvwsrli0k7ivd4937h33x9jgv4dq4w6qv3ybnz7ys754wsy1f";
      };
    });
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
      hindent
      hlint
      pretty-show
      stylish-haskell
      cabal2nix
      HaRe
    ];

    ghc801Packages = hp: with hp; [
      # hackage-diff
      # pointfree
      # HaRe
    ];

    ghc7Packages = hp: with hp; [
    ];

    haskell-env = buildEnv {
      name = "haskell-env";
      paths = [
        cabal-install
      ] ++
      (ghc801Packages (haskell.packages.ghc801.override{overrides = haskellPackageOverrides;})) ++
      (ghc8Packages (haskell.packages.ghc802.override{overrides = haskellPackageOverrides;})) ++
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
        aspell
        aspellDicts.en
        coreutils
        curl
        git
        htop
        irssi
        nox
        silver-searcher
        tig
        tmux
        zsh
        fzy
        gitAndTools.hub
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


