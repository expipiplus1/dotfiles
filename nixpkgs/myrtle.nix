{ myrtlepkgs }:
let nixpkgs = import <nixpkgs> {};
in
{
  userEnvPackages = 
    with myrtlepkgs.haskellPackages;
    [ stylish-haskell hdevtools ghc-mod hlint HaRe ];
}
