#!/usr/bin/env bash

drv=$(nix-instantiate \
  home-manager/home-manager/home-manager.nix \
  --arg confPath config/nixpkgs/home.nix \
  -A activationPackage)
echo "$drv"

paths=$(nix-store --query --requisites --include-outputs "$drv")

# shellcheck disable=2086
nix-store --realise --dry-run $paths 2> realise_output

fetchedPaths() {
  awk <realise_output '/paths will be fetched/{flag=1;next};{if (flag==1) print $1}'
}

builtDrvs() {
  awk <realise_output '/paths will be fetched/{flag=1};{if (flag==0) print $1}' | grep drv
}

fetchedPaths >fetched
builtDrvs >built
