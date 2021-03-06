{ haskell-test, pkgs, ... }:

haskell-test "vim-complete-docs" ''
  # Insert some text
  keys i
  keys $'module Foo where\n\n'; esc
  sleep 1
  keys i
  keys $'foo = putSt'

  # Observe the completion snippet suggestions
  wait_for "putStr\~ \+f \+\[LS]"
  wait_for "putStrLn\~ \+f \+\[LS]"

  # Navigate to one of them and wait for the documentation
  # to appear
  tab
  wait_for "Write a string to the standard output device"

  assert_contents ${
    pkgs.writeText "suggestion-docs" ''
      module Foo where

      foo = putStr
      ~     putStr~   f [LS]  :: String -> IO ()
      ~     putStrLn~ f [LS]  ——————————————————————————————————————————————————————————————————————————————
      ~                       Defined in 'Prelude'
      ~
      ~                       ---
      ~
      ~                       Write a string to the standard output device
      ~                        (same as  hPutStr   stdout ).* * *
      ~
      ~                       ---
      ~
      ~                       Documentation* * *
      ~                       Source
      ~
      ~                       Documentation: file:///nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-ghc-8.10.4-
      ~                       doc/share/doc/ghc/html/libraries/base-4.14.1.0/System-IO.html#v:putStr
      ~                       Source: file:///nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-ghc-8.10.4-doc/
      ~                       share/doc/ghc/html/libraries/base-4.14.1.0/src/System-IO.html#putStr
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
       INSERT  Foo.hs +                                                                                 haskell  100%    3:13
      match 1 of 2
    ''
  }
  #
''
