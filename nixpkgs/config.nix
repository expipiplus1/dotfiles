{ pkgs }:

{
  allowUnfree = true;
  allowBroken = true;

  haskellPackageOverrides = with pkgs.haskell.lib; self: super: {
    ghc-mod = overrideCabal super.ghc-mod (attrs: {
      buildDepends = [ super.binary super.haskell-src-exts_1_17_0 ];
      src = pkgs.fetchgit{ url = "git://github.com/kazu-yamamoto/ghc-mod.git";
                           rev = "54801d950a3637781c9dd23e380dd787d9e51a71";
                           sha256 = "0zc9nd6ihmqzm2i26cs0zm1gf8bryz3h8ycqw7ad3gq9zyidgb0l"; }; });
    hdevtools = overrideCabal super.hdevtools (attrs: {
      src = pkgs.fetchgit{ url = "git://github.com/schell/hdevtools.git";
                           rev = "HEAD";
                           sha256 = "06qg2xg40jc77gn7ms8h9xscja3v69paa6yb54iz1pc92l19r180"; }; });
  #haskell-src-exts = overrideCabal super.haskell-src-exts   (attrs: {
  #  buildDepends = [ super.pretty-show super.tasty-golden_2_2_2_4 ];
  #  src = pkgs.fetchgit{ url = "git://github.com/haskell-suite/haskell-src-exts.git";
  #                       rev = "0631f150ff58ac205cbe989e51c8821547cb7435";
  #                       sha256 = "09sgzyq4dihbwq5prc1g46yg6mm7xd3d6c32cjd819k2f7jnw1qz"; }; });
  #hlint   = overrideCabal super.hlint   (attrs: {
  #  src = pkgs.fetchgit{ url = "git://github.com/ndmitchell/hlint.git";
  #                       rev = "23589cfec3b875b633024743433b3822b6e867f5";
  #                       sha256 = "1wdqfpxims6gwlwil3frfjxq7rqc2h2zjfapapprlr7ialg4hxzn"; };
  #  buildDepends = [ super.refact super.haskell-src-exts_1_17_0 ]; });
   hindent = overrideCabal super.hindent (attrs: {
     doCheck = false;
     src = pkgs.fetchgit{ url = "git://github.com/chrisdone/hindent.git";
                          rev = "75a52ee4a5e22a1a4102cb135bc1ecc9681b0f98";
                          sha256 = "109lc2lv4n1z1pnggxdi4pwkp90l2xpprpy5p9d3c2k9rmr6s5y0"; }; });
    haddock = overrideCabal super.haddock (attrs: {
      src = pkgs.fetchgit{ url = "git://github.com/haskell/haddock.git";
                           rev = "ac10a4ccbe416e8612c6ca49b9f19c3a6f4cf25f";
                           sha256 = "0nmzn6p16xq0kjdpc9y5ahvqcpyqf24626krhfnl85hlcwnq8vvw"; }; });
    uom-plugin = overrideCabal super.uom-plugin (attrs: {
      src = pkgs.fetchgit{ url = "git://github.com/adamgundry/uom-plugin.git";
                           rev = "de632726bc82b078c23c65f305d0435eefa7acbf";
                           sha256 = "1v0cfvv0ggpk6jh25wibhf6wksm2pwvilzhmw4qv37nqc0f0q6lw"; } + "/uom-plugin"; });
    exact-real = overrideCabal super.exact-real (attrs: {
      src = ~/projects/exact-real;
      buildDepends = [ super.memoize ];
    });
    ad = overrideCabal super.ad (attrs: {
      src = ~/src/ad;
    });
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
                      makeWrapper
                    ];
      postInstall =
        ''
          wrapProgram "$out/bin/irssi" \
            --prefix PERL5LIB : ${perlPackages.TextAspell}/lib/perl5/site_perl/5.20.2/x86_64-linux-thread-multi \
            --prefix PERL5LIB : ${perlPackages.TextCharWidth}/lib/perl5/site_perl/5.20.2/x86_64-linux-thread-multi \
            --prefix PERL5LIB : ${perlPackages.CryptX}/lib/perl5/site_perl/5.20.2/x86_64-linux-thread-multi \
            --prefix PERL5LIB : ${perlPackages.JSON}/lib/perl5/site_perl/5.20.2
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

    # neovim = lib.overrideDerivation super.neovim (oldAttrs: {
    #   src = fetchFromGitHub {
    #     sha256 = "1sdz8k9nmc904xd0sli2z9cnbqdrk3pg5xnm6d8b24l5k4ljs6n1";
    #     rev = "0bbab3f5b9d43365b2916320aa55d69dc40d6036";
    #     repo = "neovim";
    #     owner = "expipiplus1"; };
    # });

    konsole = lib.overrideDerivation super.kdeApps_15_08.konsole (oldAttrs: {
      src = fetchgit { url = "git://anongit.kde.org/konsole";
                       rev = "7fd931601e169af8bd3b781e3946e1326eafdbfe";
                       sha256 = "1dsiah6sqdhfsc0ddga49xfkmji36d5dhj1y52jsi0j1hpkiw5qc";
                     };
    });

    devEnv = with pkgs; buildEnv {
      name = "dev-env";
      paths = [
        git
      ];
    };

    cabalPackages = hp: with hp; [
      ghc-mod
      hdevtools
      hindent
      hlint
      pretty-show
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
        (neovim.override {vimAlias = true;})
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


