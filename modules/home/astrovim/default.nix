{ lib, pkgs, ... }@inputs:
let configDir = "astrovim";
in lib.internal.simpleModule inputs "astrovim" {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [ nord-nvim vim-tmux-navigator ];
  };

  xdg.configFile = {
    # "${configDir}" = {
    #   recursive = true;
    #   source = ./astrovim;
    #   # source = pkgs.fetchFromGitHub {
    #   #   owner = "AstroNvim";
    #   #   repo = "template";
    #   #   rev = "20450d8a65a74be39d2c92bc8689b1acccf2cffe";
    #   #   sha256 = "0ljz7v64gh6vak36wx4409ipi86w3bkr53vzpgijcnvhpva0581z";
    #   # };
    # };
    # "${configDir}/lua/plugins" = {
    #   recursive = true;
    #   source = ./lua/plugins;
    # };
  };

}
