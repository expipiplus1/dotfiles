{ haskell-test, ... }:

haskell-test "vim-hls-error" ''
  slow_keys i
  slow_keys $'module Foo where\n\nfoo = () ()'
  esc
  wait_for "Couldn't match expected type"
''
