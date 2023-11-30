{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd";
    defaultOptions = [ "--bind ctrl-j:down,ctrl-k:up" ];
  };

  nixpkgs.overlays = [
    (self: super: {
      fzf = super.fzf.overrideAttrs (old: {
        patches = old.patches or [ ] ++ [ ../patches/fzf-tmux.patch ];
      });
    })
  ];

  xdg.configFile = {
    "fd/ignore".source = pkgs.writeTextFile {
      name = "fdignore";
      text = "!.github";
    };
  };
}
