{ haskell-test, assert-tmux, ... }:

haskell-test ({ pkgs, ... }: ''
  # Insert some text
  machine.send_chars("i")
  machine.send_chars("module Foo where\n\nfoo = putSt")
  machine.sleep(2)
  machine.send_key("esc")
  machine.sleep(2)
  machine.send_chars(":w\n")

  # Wait until the correct error is reported
  machine.wait_until_tty_matches(1, "Variable not in scope: putSt")

  # Open the diagnostics list and see if it's as we expect
  leader = " "
  machine.send_chars(f"{leader}d")
  machine.wait_until_tty_matches(1, "[Dd]iagnostics")
  # fzf might take some time to loader this
  machine.wait_until_tty_matches(1, "1 module Foo where")

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
