#!/usr/bin/env bash
#!nix-shell -i bash -p git

cd "$HOME" || exit
mkdir -p src
cd src || exit

git clone https://github.com/nixos/nixpkgs
cd nixpkgs || exit
git remote add channels https://github.com/nixos/nixpkgs-channels

cd "$HOME/src" || exit
git clone https://github.com/rycee/home-manager
cd home-manager || exit
git remote add expipiplus1 https://github.com/expipiplus1/home-manager
git fetch expipiplus1
git checkout --track expipiplus1/joe

nix-shell . -A install

rm "$HOME/.config/nixpkgs/home.nix"
ln -s "$HOME/dotfiles/config/nixpkgs/home.nix" "$HOME/.config/nixpkgs/home.nix"

NIX_PATH="nixpkgs=$HOME/src/nixpkgs:home-manager=$HOME/src/home-manager" home-manager switch
