# My system configuration

Main config in [./config/nixpkgs/home.nix](./config/nixpkgs/home.nix)

## Setting up

Run `install.sh` and `misc.sh`, the latter is idempotent.

```
nix-shell -p git home-manager
git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
homeshick clone git@github.com:expipiplus1/dotfiles.git
ln -s .homesick/repos/dotfiles dotfiles
home-manager switch
atuin login
atuin sync
sudo ln -s /home/e/dotfiles/flake.nix nixos/flake.nix
sudo nixos-rebuild switch
```

## Passwords

Restic repo and password in `~/.ssh/restic/{repo,password}`
