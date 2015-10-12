#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

shopt -s extglob

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files=!(install.sh)

##########

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
  if [ -f $file ];
  then
    mkdir -p $olddir
    echo "Moving existing $file from ~ to $olddir"
    mv ~/.$file ~/dotfiles_old/
  fi 
  ln -sv $dir/$file ~/.$file
done
