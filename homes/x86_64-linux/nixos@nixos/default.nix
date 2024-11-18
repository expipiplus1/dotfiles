{ pkgs, ... }: {
  ellie.basic.enable = true;
  ellie.zsh.enable = true;
  ellie.fzf.enable = true;
  ellie.git.enable = true;
  ellie.tmux.enable = true;
  ellie.neovim.enable = true;
  ellie.neovim.hasFcitx5 = true;
  ellie.gdb.enable = true;
  ellie.direnv.enable = true;
  ellie.atuin.enable = true;
  ellie.haskell.enable = true;
  ellie.tex.enable = true;
  # wsl.enable = true;
}
