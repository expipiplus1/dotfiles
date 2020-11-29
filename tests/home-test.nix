{ pkgs ? import <nixpkgs> { }, capture-golden ? false }: rec {
  inherit pkgs;

  home = import ../home-manager/modules {
    inherit pkgs;
    configuration = toString ../config/nixpkgs/home.nix;
  };

  activation = pkgs.runCommand "bin-activation" { } ''
    mkdir -p "$out"/bin
    ln -s ${home.activationPackage}/activate "$out"/bin/activate
  '';

  make-test = name: inputs: test:
    with pkgs;
    # Which for https://github.com/haskell/vscode-haskell/issues/327
    pkgs.runCommand name { nativeBuildInputs = inputs ++ [ which ]; } ''
      wait_for() {
        p=$1
        n=30
        for (( i=1; i<=$n; i++ )); do
          tmux capture-pane -p > pane-contents
          if [ $i -eq $n ]; then
            echo "Last chance waiting for \"$p\" to appear"
            echo "Current pane contents:"
            cat pane-contents
          fi
          if grep -q "$p" pane-contents; then
            return
          fi
          sleep 1
        done
        return 1
      }
      assert_contents() {
        golden=$1
        actual=actual
        tmux capture-pane -p |
          ${pkgs.perl}/bin/perl -pe "s|/nix/store/[a-z0-9]{32}-|/nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g" \
          > "$actual"
        diff "$golden" "$actual"
      }
      slow_keys() {
        str=$1
        for (( i=0; i<''${#str}; i++ )); do
          tmux send-keys "''${str:$i:1}"
          sleep 0.1
        done
      }
      enter() {
        tmux send-keys Enter
      }
      esc() {
        tmux send-keys Escape
      }
      tab() {
        tmux send-keys Tab
      }

      #
      # Stuff home-manager script wants
      #
      export HOME=$(mktemp -d)
      export USER=user
      export NIX_STORE=$(mktemp -d)
      export NIX_STATE_DIR=$NIX_STORE/var
      mkdir -p $NIX_STATE_DIR/gcroots/per-user/$USER/

      # Make a phony nix-env and nix-build so the activation script doesn't try
      # to fiddle with the Nix store
      mkdir -p bin
      echo "#!${bash}/bin/bash" > bin/nix-env
      chmod +x bin/nix-env
      echo "#!${bash}/bin/bash" > bin/nix-build
      chmod +x bin/nix-build
      PATH=$(pwd)/bin:$PATH

      # Put links in home directory, do the path insertion manually, seems to
      # be good enough
      ${activation}/bin/activate
      PATH=${home.config.home.path}/bin:$PATH

      # Start the tmux session in which we'll do the interaction
      tmux new-session -d -x 120 -y 40

      ${test}
      mkdir -p "$out"
      tmux capture-pane -p >"$out/final-contents" || :
    '';

  # Create a vim session editing a file "Foo.hs" with a direct cradle with no arguments
  haskell-test = name: test:
    make-test name [ pkgs.ghc ] ''
      # Create a hie.yaml to avoid any warnings/infos
      echo $'cradle:\n  direct:\n    arguments: []' > hie.yaml

      # Start vim
      slow_keys vim; enter
      wait_for "NORMAL"
      slow_keys $':e Foo.hs\n'
      wait_for "NORMAL.*Foo.hs"
      # let vim collect itself
      sleep 1

      # Run the Vim+Haskell test
      ${test}
    '';
}
