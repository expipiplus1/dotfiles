with (import ./home-test.nix { capture-golden = false; });

haskell-test ({ pkgs, ... }: ''
  # Insert some text
  machine.send_chars("i")
  machine.send_chars("module Foo where\n\nfoo = putSt")
  machine.send_key("esc")
  machine.send_chars(":w\n")

  # Wait until an error is reported
  machine.wait_until_tty_matches(1, "E1")

  # Open the diagnostics list and see if it's as we expect
  leader = " "
  machine.send_chars(f"{leader}d")
  machine.wait_until_tty_matches(1, "[Dd]iagnostics")

  ${assert-tmux pkgs "fzf-diagnostics" ''
      module Foo where

    > foo = putSt ▷ • Variable not in scope: putSt \ • Perhaps you meant ‘putStr’ (imported from Prelude)
    ~            [typecheck] [E] • Variable not in scope: putSt
    ~            • Perhaps you meant ‘putStr’ (imported from Prelude)
    ~
    ~
    ~
    ~
    ~
    ~     ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    ~     │ ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
    ~     │ │    1 module Foo where                                                                                       │ │
    ~     │ │    2                                                                                                        │ │
    ~     │ │    3 foo = putSt                                                                                            │ │
    ~     │ │                                                                                                             │ │
    ~     │ │                                                                                                             │ │
    ~     │ │                                                                                                             │ │
    ~     │ │                                                                                                             │ │
    ~     │ │                                                                                                             │ │
    ~     │ │                                                                                                             │ │
    ~     │ │                                                                                                             │ │
    ~     │ │                                                                                                             │ │
    ~     │ ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
    ~     │ > Foo.hs:3:7 Error [typecheck] • Variable not in scope: putSt • Perhaps you meant ‘putStr’ (imported from Pr..  │
    ~     │                                                                                                                 │
    ~     │                                                                                                                 │
    ~     │                                                                                                                 │
    ~     │                                                                                                                 │
    ~     │                                                                                                                 │
    ~     │                                                                                                                 │
    ~     │                                                                                                                 │
    ~     │                                                                                                                 │
    ~     │                                                                                                                 │
    ~     │                                                                                                                 │
    ~     │   1/1 (0)                                                                                                       │
    ~     │ Coc Diagnostics>                                                                                                │
    ~     └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    ~
    ~
    ~
    ~
    ~
    ~
    ~
    ~
     Foo.hs                                                                                                   haskell  100%    3:11
    "Foo.hs" line 3 of 3 --100%-- col 11
  ''}
  #
'')