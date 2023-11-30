{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "fzf" {
  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd";
    defaultOptions = [ "--bind ctrl-j:down,ctrl-k:up" ];
  };

  xdg.configFile = {
    "fd/ignore".source = pkgs.writeTextFile {
      name = "fdignore";
      text = "!.github";
    };
  };
}
