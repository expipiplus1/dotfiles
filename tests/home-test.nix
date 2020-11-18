{ capture-golden ? false }: rec {
  make-test = f: import <nixpkgs/nixos/tests/make-test-python.nix> f { };
  home-test = test:
    make-test ({ pkgs, ... }:
      let
        home-manager = import <home-manager/home-manager/home-manager.nix> {
          confPath = "/home/j/.config/nixpkgs/home.nix";
        };
        activation = pkgs.runCommand "bin-activation" { } ''
          mkdir -p "$out"/bin
          ln -s ${home-manager.activationPackage}/activate "$out"/bin/activate
        '';
      in {
        name = "vim";
        machine = { ... }: {
          imports = [ <nixpkgs/nixos/tests/common/user-account.nix> ];
          environment.systemPackages = [ pkgs.vim pkgs.ghc activation ];
          # Work around https://github.com/haskell/ghcide/issues/911
          virtualisation.cores = 2;
          virtualisation.memorySize = 512;

          i18n.defaultLocale = "en_us.UTF-8";
        };
        # enableOCR = true;
        testScript = { nodes, ... }:
          let
            user = nodes.machine.config.users.users.alice;
            su = command: "su - ${user.name} -c '${command}'";
            # such quoting
            tmux = args: ''machine.succeed(f"""${su "tmux ${args}"}""")'';
          in ''
            # fmt: off
            def nuke_references(filename: str):
                d = "/tmp/nuked"
                r = os.path.join(d, os.path.basename(filename))
                machine.succeed(f"mkdir -p {d}")
                machine.succeed(
                  f'${pkgs.perl}/bin/perl -pe "s|\Q$NIX_STORE\E/[a-z0-9]{{32}}-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g" < "{filename}" > {r}'
                )
                return r


            def dump_tmux(filename: str):
                ${tmux "capture-pane -b temp-capture-buffer -S -"}
                ${tmux "save-buffer -b temp-capture-buffer {filename}"}
                ${tmux "delete-buffer -b capture-buffer"}
                r = nuke_references(filename)
                machine.succeed(f'mv "{r}" "{filename}"')


            # Compare a golden string to the current tmux contents
            def compare_tmux(golden: str, name: str, tty: str = 1):
                actual = f"/tmp/{name}"
                dump_tmux(actual)
                machine.succeed(f'diff "{golden}" "{actual}"')


            # Save the tmux contents with a name
            def capture_tmux(filename: str):
                actual = f"/tmp/{filename}"
                dump_tmux(actual)
                machine.copy_from_vm(actual)


            machine.wait_for_unit("multi-user.target")
            machine.wait_until_succeeds("pgrep -f 'agetty.*tty1'")

            # Activate our home-manager setup
            machine.succeed("${su "activate"}")

            # Login
            machine.wait_until_tty_matches(1, "login: ")
            machine.send_chars("${user.name}\n")
            machine.wait_until_tty_matches(1, "Password: ")
            machine.send_chars("${user.password}\n")
            machine.wait_until_tty_matches(1, "${user.name}@machine")

            # Start a tmux session, we use tmux because capturing seems to work
            # much better than get_tty_contents or screendump (regarding non
            # ASCII chars)
            machine.send_chars("tmux\n")
            machine.wait_until_tty_matches(1, re.compile("^~", re.MULTILINE))
          '' + test {
            inherit pkgs user;
            inherit (nodes) machine;
          };
      });

  # Create a vim session editing a file "Foo.hs" with a direct cradle with no arguments
  haskell-test = test:
    home-test ({ user, ... }@args:
      (''
        machine.succeed('echo "cradle:\n  direct:\n    arguments: []" > ${user.home}/hie.yaml')
        machine.send_chars("vim\n")
        machine.wait_until_tty_matches(1, "NORMAL")
        machine.send_chars(":e Foo.hs\n")
        machine.wait_until_tty_matches(1, "NORMAL.*Foo.hs")
        # let vim collect itself
        machine.sleep(3)
          '' + test args));

  assert-tmux = pkgs: name: contents:
    let f = pkgs.writeText name contents;
    in if capture-golden then ''
      capture_tmux("${name}")
    '' else ''
      compare_tmux("${f}", "${name}")
    '';
}
