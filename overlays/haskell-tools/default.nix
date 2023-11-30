{ ... }:

self: super: {
  docServer = self.writeShellScriptBin "doc-server" ''
    shopt -s nullglob
    dir=''${1:-.}
    if [ -f flake.nix ]; then
      printf '%s\n' flake.nix *.cabal *.package.yaml |
        ${self.entr}/bin/entr -r -- \
          sh -c "direnv reload && direnv exec . hoogle server --local"
    elif [ -f package.yaml ]; then
      echo package.yaml |
        ${self.entr}/bin/entr -r -- \
          sh -c "hpack && cached-nix-shell $dir --keep XDG_DATA_DIRS --run 'hoogle server --local'"
    else
      echo *.cabal |
        ${self.entr}/bin/entr -r -- \
          sh -c "cached-nix-shell $dir --keep XDG_DATA_DIRS --run 'hoogle server --local'"
    fi
  '';

  haskell-language-server =
    super.haskell-language-server.override { supportedGhcVersions = [ "94" ]; };

  hackage-release = self.writeShellScriptBin "hackage-release" ''
    ${self.gitAndTools.hub}/bin/hub release download "$1" |
      cut -d' ' -f2 |
      sort -r |
      while read f; do
        if [[ "$f" =~ "-docs.tar.gz" ]]; then
          ${self.cabal-install}/bin/cabal upload --publish --doc "$f"
        else
          ${self.cabal-install}/bin/cabal upload --publish "$f"
        fi
        rm "$f"
      done
  '';
}
