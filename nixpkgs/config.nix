{ pkgs }:
{
  allowUnfree = true;
  allowBroken = true;

  haskellPackageOverrides = with pkgs.haskell.lib; self: super: {
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
      pretty-show
      shake
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


