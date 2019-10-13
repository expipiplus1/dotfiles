#!/usr/bin/env bash
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
       config/nixpkgs/home.nix
       nixpkgs/config.nix
       nixpkgs/plugs.nix
       nixpkgs/vim.nix
       ghci
       aspell.conf
       xinitrc
       xkb/symbols/local
       xkb/types/local
       xkb/keymap/custom
       XCompose
       Xmodmap
       haskeline
       brittany
       stylish-haskell
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

gsettings set org.gnome.desktop.media-handling automount-open false
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"
