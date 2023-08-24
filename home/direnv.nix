{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  nixpkgs.overlays = [
    (self: super: {
      direnv = super.direnv.overrideAttrs (old: {
        patches = old.patches or [ ] ++ [ ../patches/quiet-direnv.patch ];
      });
    })
  ];

  programs.zsh.initExtra = ''
    export DIRENV_LOG_FORMAT=$(printf "\e[1;30""mdirenv: %%s\e[0")
  '';
}
