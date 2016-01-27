#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

shopt -s extglob

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files="bashrc
       tmux.conf
       tmux/plugins/tpm
       config/nvim/init.vim
       config/nvim/autoload/plug.vim
       config/base16-shell
       nixpkgs/config.nix
       stack/stack.yaml
       ghci
       irssi
       gitconfig
       Xmodmap
      "

##########

echo "updating submodules"
git submodule update --init

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do
  if [[ -e ~/.$file ]];
  then
    mkdir -p $olddir
    echo "Moving existing ~/.$file from ~ to $olddir/.$file"
    mkdir -p $(dirname $olddir/.$file)
    mv ~/.$file $olddir/.$file
  fi
  mkdir -p $(dirname ~/.$file)
  ln -sv $dir/$file ~/.$file
done

