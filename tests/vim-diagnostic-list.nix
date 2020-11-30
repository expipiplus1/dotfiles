{ haskell-test, pkgs, ... }:

haskell-test "vim-diagnostic-list" ''
  # Insert some text
  keys i
  keys $'module Foo where\n\nfoo = putSt'; esc
  keys :w; enter

  # Wait until the correct error is reported
  wait_for "Variable not in scope: putSt"

  # Open the diagnostics list and see if it's as we expect
  leader=" "
  keys "''${leader}d"
  wait_for "[Dd]iagnostics"
  # fzf might take some time to load this
  wait_for "1 module Foo where"

  assert_contents ${
    pkgs.writeText "fzf-diagnostics" ''
        module Foo where

      > foo = putSt ▷ • Variable not in scope: putSt \ • Perhaps you meant ‘putStr’ (imported from Prelude)
      ~            [typecheck] [E] • Variable not in scope: putSt
      ~            • Perhaps you meant ‘putStr’ (imported from Prelude)
      ~
      ~
      ~
      ~     ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
      ~     │ ╭──────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
      ~     │ │    1 module Foo where                                                                                │ │
      ~     │ │    2                                                                                                 │ │
      ~     │ │    3 foo = putSt                                                                                     │ │
      ~     │ │                                                                                                      │ │
      ~     │ │                                                                                                      │ │
      ~     │ │                                                                                                      │ │
      ~     │ │                                                                                                      │ │
      ~     │ │                                                                                                      │ │
      ~     │ │                                                                                                      │ │
      ~     │ ╰──────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
      ~     │ > Foo.hs:3:7 Error [typecheck] • Variable not in scope: putSt • Perhaps you meant ‘putStr’ (imported ..  │
      ~     │                                                                                                          │
      ~     │                                                                                                          │
      ~     │                                                                                                          │
      ~     │                                                                                                          │
      ~     │                                                                                                          │
      ~     │                                                                                                          │
      ~     │                                                                                                          │
      ~     │                                                                                                          │
      ~     │   1/1 (0)                                                                                                │
      ~     │ Coc Diagnostics>                                                                                         │
      ~     └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
      ~
      ~
      ~
      ~
      ~
      ~
       Foo.hs                                                                                           haskell  100%    3:11
      "Foo.hs" line 3 of 3 --100%-- col 11
    ''
  }
  #
''
