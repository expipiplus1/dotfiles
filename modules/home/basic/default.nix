{
  lib,
  config,
  pkgs,
  ...
}@inputs:
lib.internal.simpleModule inputs "basic" {
  home.username = "e";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
  home.homeDirectory = "/home/e";

  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    NIX_PATH = "nixpkgs=$HOME/src/nixpkgs";
    EDITOR = "vim";
    NIXOS_OZONE_WL = 1;
    SSH_ASKPASS_REQUIRE = "prefer";
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };

  home.packages =
    with pkgs;
    [
      # Cross-platform clipboard scripts
      (
        let
          clipCmd =
            if stdenv.isDarwin then
              "pbcopy"
            else
              ''
                if [[ -n "$WSL_DISTRO_NAME" ]]; then clip.exe
                elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then ${wl-clipboard}/bin/wl-copy
                else ${xclip}/bin/xclip -selection clipboard -in; fi
              '';
        in
        writeShellScriptBin "copy" ''
          cat "''${@:--}" | ${clipCmd}
        ''
      )

      (
        let
          cmd =
            if stdenv.isDarwin then
              "pbpaste"
            else
              ''
                if [[ -n "$WSL_DISTRO_NAME" ]]; then powershell.exe -Command Get-Clipboard
                elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then ${wl-clipboard}/bin/wl-paste
                else ${xclip}/bin/xclip -selection clipboard -out; fi
              '';
        in
        writeShellScriptBin "pasta" cmd
      )

      (pkgs.writeShellApplication {
        name = "rotate";
        runtimeInputs = [
          libjpeg
          imagemagick
        ];
        text = ''
          usage() {
            echo "Usage: rotate [-l|--allow-lossy] -N FILE..." >&2
            echo "Rotate image(s) losslessly by 90*N degrees clockwise" >&2
            echo "" >&2
            echo "  -N             Number of 90° rotations (1-3)" >&2
            echo "  -l, --allow-lossy  Fall back to lossy rotation for JPEGs" >&2
            echo "                     with non-standard MCU sizes" >&2
            echo "  -h, --help     Show this help" >&2
            exit "''${1:-1}"
          }

          allow_lossy=0
          degrees=""
          files=()

          while [[ $# -gt 0 ]]; do
            case "$1" in
              -h|--help) usage 0 ;;
              -l|--allow-lossy) allow_lossy=1; shift ;;
              -[1-3]) degrees=$(( ''${1#-} * 90 )); shift ;;
              -*) echo "rotate: unknown option: $1" >&2; usage ;;
              *) files+=("$1"); shift ;;
            esac
          done

          [[ -z "$degrees" ]] && { echo "rotate: missing rotation argument" >&2; usage; }
          [[ ''${#files[@]} -eq 0 ]] && { echo "rotate: no files specified" >&2; usage; }

          for file in "''${files[@]}"; do
            if [[ ! -f "$file" ]]; then
              echo "rotate: $file: No such file" >&2
              continue
            fi

            mime=$(file --brief --mime-type "$file")
            case "$mime" in
              image/jpeg)
                tmp=$(mktemp "''${file}.XXXXXX")
                if [[ "$allow_lossy" -eq 1 ]]; then
                  if jpegtran -rotate "$degrees" -copy all -outfile "$tmp" "$file"; then
                    mv "$tmp" "$file"
                  else
                    rm -f "$tmp"
                    echo "rotate: $file: jpegtran failed" >&2
                  fi
                else
                  if jpegtran -rotate "$degrees" -perfect -copy all -outfile "$tmp" "$file"; then
                    mv "$tmp" "$file"
                  else
                    rm -f "$tmp"
                    echo "rotate: $file: lossless rotation failed (try --allow-lossy)" >&2
                  fi
                fi
                ;;
              *)
                magick "$file" -rotate "$degrees" "$file"
                ;;
            esac
          done
        '';
      })

      bat
      bear
      bmon
      btop
      cached-nix-shell
      coreutils
      curl
      difftastic
      dnsutils
      dust
      duf
      entr
      fd
      file
      gh
      gist
      hackage-release
      htop
      jq
      # json2nix
      killall
      lsd
      mosh
      nix
      nix-output-monitor
      nix-prefetch-git
      nix-prefetch-github
      nmap
      openssl
      perl
      ripgrep
      rust-parallel
      silver-searcher
      tio
      tree
      tssh
      unzip
      yq
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      lm_sensors
      efibootmgr
    ];

  xdg.configFile = {
    "yamllint/config".source = pkgs.writeTextFile {
      name = "yamllint-config";
      text = builtins.toJSON {
        extends = "relaxed";
        rules.line-length.max = 120;
      };
    };
    "sccache/config".text = builtins.concatStringsSep "\n" [
      "[cache.disk]"
      "size = 100000000000"
    ];
  };
}
