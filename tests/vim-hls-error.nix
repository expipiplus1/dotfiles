{ haskell-test, ... }:

haskell-test "vim-hls-error" ''
  keys i
  keys $'module Foo where\n\nfoo = () ()'
  esc
  wait_for "Couldn't match expected type"
''
