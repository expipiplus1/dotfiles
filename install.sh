#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

shopt -s extglob

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files="agignore
       bashrc
       tmux.conf
       tmux/plugins/tpm
       config/nvim/init.vim
       config/nvim/autoload/plug.vim
       config/base16-shell
       nixpkgs/config.nix
       nixpkgs/plugs.nix
       nixpkgs/vim.nix
       stack/config.yaml
       ghci
       irssi
       gitconfig
       aspell.conf
       xinitrc
       xkb/symbols/local
       moc/config
       moc/themes/base16
       zshrc
       XCompose
      "

##########

echo "updating submodules"
git submodule update --init

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do
  if [[ -e ~/.$file ]]; then
    mkdir -p $olddir
    if [[ -e $olddir/.$file ]]; then
      echo "Removing $olddir/.$file"
      rm -r $olddir/.$file
    fi
    echo "Moving existing ~/.$file from ~ to $olddir/.$file"
    mkdir -p $(dirname $olddir/.$file)
    mv ~/.$file $olddir/.$file
  fi
  mkdir -p $(dirname ~/.$file)
  ln -sv $dir/$file ~/.$file
done

