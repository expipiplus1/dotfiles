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
    monad-memo = overrideAttrs super.monad-memo {
      doCheck = false;
    };
    iridium = overrideAttrs super.iridium {
      jailbreak = true;
    };
    HaRe = overrideAttrs super.HaRe {
      doCheck = false;
    };
    brittany = overrideAttrs super.brittany {
      src = pkgs.fetchFromGitHub {
        owner = "lspitzner";
        repo = "brittany";
        rev = "1330aeb6b4d3a3138bca89e1f3ee966677ee93db";
        sha256 = "0n26jqx67ipkflkqw4n7ll64cv07dskxyjcxlvrvjgwwnajdl5p3";
      };
      jailbreak = true;
    };
    ghc-exactprint = overrideAttrs super.ghc-exactprint {
      src = pkgs.fetchFromGitHub {
        owner = "alanz";
        repo = "ghc-exactprint";
        rev = "e9532ae3e4222c5a022cad0c8f9bbcb0adf6d55a";
        sha256 = "0x0sj5ghw099iv755amdy9im44vwrfaj0nsvzas06q3lj3p1140i";
      };
    };
    multistate = overrideAttrs super.multistate {
      src = pkgs.fetchFromGitHub {
        owner = "lspitzner";
        repo = "multistate";
        rev = "9c56d3070fa8e6cdfa0e21ebd191efdd30a20b66";
        sha256 = "1v7j93wcffrc3pqbfi93l4zc1cash38bnjhvzpqwv644rcyjpgnh";
      };
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

    neovim-unconfigured = super.neovim;
    neovim-rtp = (import ./vim.nix {inherit pkgs neovim-unconfigured;}).rtpFile;
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
        ${pkgs.mosh}/bin/mosh "$@" -- tmux attach
      '';
      executable = true;
      destination = "/bin/tssh";
    };

    upfind = import (pkgs.fetchFromGitHub {
      owner = "expipiplus1";
      repo = "upfind";
      rev = "325f7f5be5f051ba7b54f38534f69e511b020fea";
      sha256 = "1nvk941k649m9v9pgskqnmyknvp32hxq8cg70cjy50c8kqj1lj0r";
    }) {inherit pkgs;};

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
      brittany
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
        asciinema
        aspell
        aspellDicts.en
        clang-tools
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
        tree
        gist
        gitAndTools.hub
        jq
        tssh
        file
        binutils
        mosh
        upfind
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


