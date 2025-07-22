{ lib, config, ... }:
let prefix = "ellie";
in with lib; {
  options.${prefix}.common = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.${prefix}.common.enable {
    ellie.astronvim.enable = true;
    ellie.atuin.enable = true;
    ellie.basic.enable = true;
    ellie.carapace.enable = true;
    ellie.direnv.enable = true;
    ellie.fzf.enable = true;
    ellie.gdb.enable = true;
    ellie.git.enable = true;
    ellie.jujutsu.enable = true;
    ellie.starship.enable = true;
    ellie.tmux.enable = true;
    ellie.zsh.enable = true;
    nixpkgs.config.allowUnfree = true;
  };
}
