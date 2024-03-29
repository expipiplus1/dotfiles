{ haskell-test, pkgs, ... }:

haskell-test "vim-format-function" ''
  # Insert some text
  keys i
  keys $'module Foo where\n\nfoo =\nfoo'; esc

  # Wait for the text
  wait_for "NORMAL"

  leader=" "
  keys "''${leader}f"
  wait_for "foo = foo"
  wait_for "foo :: t"

  assert_contents ${
    pkgs.writeText "fzf-diagnostics" ''
      module Foo where
      foo = foo ‣ foo :: t
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
      ~
       NORMAL  Foo.hs +                                                                                 haskell  100%    2:7
      3 lines filtered
    ''
  }
  #
''
