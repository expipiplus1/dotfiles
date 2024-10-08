{ pkgs, ... }: {
  ellie.basic.enable = true;
  ellie.zsh.enable = true;
  ellie.fzf.enable = true;
  ellie.git.enable = true;
  ellie.jujutsu.enable = true;
  ellie.tmux.enable = true;
  ellie.neovim.hasFcitx5 = true;
  ellie.gdb.enable = true;
  ellie.direnv.enable = true;
  ellie.atuin.enable = true;
  ellie.haskell.enable = true;
  ellie.neovim.enable = false;
  ellie.astrovim.enable = true;
  ellie.wsl.enable = true;
}
