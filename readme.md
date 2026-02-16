# NixOS + Home Manager Dotfiles

Snowfall Lib-based configuration.

## New Desktop

**System** (`systems/x86_64-linux/<hostname>/default.nix`):
```nix
{ lib, ... }: {
  imports = [ ./hardware ];
  ellie.desktop.enable = true;
}
```

**Home** (`homes/x86_64-linux/e@<hostname>/default.nix`):
```nix
{ ... }: {
  ellie.common.enable = true;
  ellie.pc.enable = true;
}
```

## New Server

**System**:
```nix
{ lib, ... }: {
  imports = [ ./hardware ];
  ellie.users.enable = true;
}
```

**Home**:
```nix
{ ... }: {
  ellie.common.enable = true;
}
```

## Installation

```bash
nix-shell -p git home-manager
git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
homeshick clone git@github.com:expipiplus1/dotfiles.git
ln -s .homesick/repos/dotfiles dotfiles

home-manager switch
atuin login
atuin sync

sudo ln -sf /home/e/dotfiles/flake.nix /etc/nixos/flake.nix
sudo nixos-rebuild switch --flake /etc/nixos
```

## Passwords

Restic repo and password in `~/.ssh/restic/{repo,password}`
