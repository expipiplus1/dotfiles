{ haskell-test, ... }:

haskell-test ({ ... }: ''
  machine.send_chars("i")
  machine.send_chars("module Foo where\n\nfoo = () ()")
  machine.send_key("esc")
  machine.wait_until_tty_matches(1, "Couldn't match expected type")
  machine.send_chars("ZZ\n")
'')
