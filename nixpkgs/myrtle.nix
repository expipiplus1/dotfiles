{ myrtlepkgs }:
{
  userEnvPackages = 
    with myrtlepkgs.haskellPackages;
    [ stylish-haskell hdevtools ghc-mod hlint HaRe hindent brittany ];
}
