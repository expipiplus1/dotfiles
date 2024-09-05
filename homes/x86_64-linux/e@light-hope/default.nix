{ pkgs, ... }: {
  ellie.basic.enable = true;
  ellie.zsh.enable = true;
  ellie.fzf.enable = true;
  ellie.git.enable = true;
  ellie.tmux.enable = true;
  ellie.kakoune.enable = false;
  ellie.helix.enable = false;
  ellie.pc.enable = true;
  ellie.gdb.enable = true;
  ellie.direnv.enable = true;
  ellie.atuin.enable = true;
  ellie.sensors.enable = true;
  ellie.dual-boot.enable = true;
  ellie.autostart.enable = true;
  ellie.jujutsu.enable = true;
  ellie.tg.enable = true;
  # ellie.neovim.enable = true;
  ellie.astrovim.enable = true;
}
