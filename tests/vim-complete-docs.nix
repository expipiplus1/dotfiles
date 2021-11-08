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
        foo = putStr ‣ foo :: String -> IO ()
      ~       putStr~        f [LS]    :: String -> IO ()
      ~       putStr~        f [LS]    ──────────────────────────────────────────────────────────────────────────────
      ~       putStr~        f [LS]    Defined in 'Prelude'
      ~       putStr~        f [LS]
      ~       putStr~        f [LS]    ---
      ~       putStr~        f [LS]
      ~       putStr~        f [LS]    Write a string to the standard output device
      ~       putStr~        f [LS]     (same as  hPutStr   stdout ).* * *
      ~       putStr~        f [LS]
      ~       putStrLn~      f [LS]    ---
      ~       putStrLn~      f [LS]
      ~       putStrLn~      f [LS]    Documentation* * *
      ~       putStrLn~      f [LS]    Source
      ~       putStrLn~      f [LS]
      ~       putStrLn~      f [LS]    Documentation: file:///nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-ghc-8.10.7-
      ~       putStrLn~      f [LS]    doc/share/doc/ghc/html/libraries/base-4.14.3.0/System-IO.html#v:putStr
      ~       putStrLn~      f [LS]    Source: file:///nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-ghc-8.10.7-doc/
      ~       putStringUtf8~ f [LS]    share/doc/ghc/html/libraries/base-4.14.3.0/src/System-IO.html#putStr
      ~       putStringUtf8~ f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStr~       f [LS]
      ~       hPutStrLn~     f [LS]
      ~       hPutStrLn~     f [LS]
      ~       hPutStrLn~     f [LS]
      ~       hPutStrLn~     f [LS]
      ~       hPutStrLn~     f [LS]
      ~       hPutStrLn~     f [LS]
      ~       hPutStrLn~     f [LS]
       INSERT hPutStrLn~     f [LS]                                                                     haskell  100%    2:15
      match 1 of 39
    ''
  }
  #
''
