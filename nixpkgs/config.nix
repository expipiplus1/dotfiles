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

  tex = with pkgs;
    texlive.combine{
      inherit (texlive)
              amsmath
              babel
              beamer
              unicode-math
              ucharcat
              filehook
              booktabs
              cm-super
              collection-fontsextra
              collection-fontsrecommended
              ec
              etoolbox
              euenc
              fontspec
              greek-inputenc
              lm
              mathspec
              pgf
              pgfgantt
              pgfkeyx
              scheme-basic
              siunitx
              standalone
              xcolor
              xetex
              xkeyval
              xunicode
              zapfding
              microtype
              draftwatermark
              everypage
              metafont
              koma-script
              parskip
              mdframed
              needspace
              wallpaper
              eso-pic
              ;
    };

  packageOverrides = super: let pkgs = super.pkgs; in with pkgs; rec {

    asciidoctor =
      (import (builtins.getEnv "HOME" + "/src/nixpkgs2") {config = {};}).asciidoctor;

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

    weechat = super.weechat.override {
      # aspell = pkgs.aspellWithDicts (ps: [ps.en]);
      # useEnchant = true;
      # enchantHunspellDicts = [pkgs.hunspellDicts.en-us];
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
      (ghc8Packages (haskell.packages.ghc864.override{overrides = haskellPackageOverrides;})) ++
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

    #
    # Everything I want
    #
    dev-env = buildEnv {
      name = "dev-env";
      paths = [
        asciinema
        (aspellWithDicts (ps: with ps; [en]))
        aspellDicts.en
        bmon
        clang-tools
        coreutils
        curl
        file
        fzf
        fzy
        gist
        htop
        jq
        mosh
        nox
        silver-searcher
        tig
        tree
        tssh
        glibcLocales
        graphviz
      ];
    };

    pandocEnv = buildEnv {
      name = "pandoc-env";
      paths = [
        pandoc
        pdftk
        tex
      ];
    };
  };
}


