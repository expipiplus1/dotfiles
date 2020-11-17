with (import ./home-test.nix { capture-golden = false; });

haskell-test ({ pkgs, ... }: ''
  # Insert some text
  machine.send_chars("i")
  machine.send_chars("module Foo where\n\nfoo = putSt")

  # Observe the completion suggestions
  machine.wait_until_tty_matches(1, r"putStr +f +\[LS]")
  machine.wait_until_tty_matches(1, r"putStrLn +f +\[LS]")

  # Navigate to one of them and wait for the documentation
  # to appear
  machine.send_key("tab")
  machine.wait_until_tty_matches(
      1, re.escape("Write a string to the standard output device")
  )

  ${assert-tmux pkgs "suggestion-docs" ''
    module Foo where

    foo = putStr ‣ foo :: String -> IO ()
    ~     putStr   f [LS]  :: String -> IO ()
    ~     putStrLn f [LS]  ——————————————————————————————————————————————————————————————————————————————
    ~                      Defined in 'Prelude'
    ~
    ~                      ---
    ~
    ~                      Write a string to the standard output device
    ~                       (same as  hPutStr   stdout ).*    *    *
    ~
    ~                      ---
    ~
    ~                      [Documentation](file:///nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-ghc-8.8.4-
    ~                      doc/share/doc/ghc/html/libraries/base-4.13.0.0/System-IO.html#v:
    ~                      putStr)*    *    *
    ~                      [Source](file:///nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-ghc-8.8.4-doc/
    ~                      share/doc/ghc/html/libraries/base-4.13.0.0/src/System-IO.html#putStr)
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
     INSERT  Foo.hs +                                                                                         haskell  100%    3:13
    match 1 of 2
  ''}
  #
'')
