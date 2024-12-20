{ lib, pkgs, ... }@inputs:
let
  configDir = "astronvim";
  lspEnv = pkgs.buildEnv {
    name = "lsp-servers";
    paths = with pkgs; [
      haskellPackages.cabal-gild

      idris2Packages.idris2Lsp

      clang-tools

      cmake-language-server

      python3Packages.python-lsp-server
      python3Packages.rope
      python3Packages.yapf
      python3Packages.flake8
      python3Packages.pylint

      nil
      nixd

      nodePackages.prettier

      tree-sitter

      lua51Packages.neotest

      rust-analyzer

      nodePackages.bash-language-server
      shfmt
      shellcheck

      marksman

      nodePackages.vscode-json-languageserver
      yaml-language-server

      lua5_1
      lua-language-server
      luarocks
      stylua
      selene

      golangci-lint
    ];
  };

  treesitter-grammars = let
    grammars = lib.filterAttrs (n: _: lib.hasPrefix "tree-sitter-" n)
      pkgs.vimPlugins.nvim-treesitter.builtGrammars;
    symlinks = lib.mapAttrsToList (name: grammar:
      "ln -s ${grammar}/parser $out/${lib.removePrefix "tree-sitter-" name}.so")
      grammars;
  in (pkgs.runCommand "treesitter-grammars" { } ''
    mkdir -p $out
    ${lib.concatStringsSep "\n" symlinks}
  '').overrideAttrs
  (_: { passthru.rev = pkgs.vimPlugins.nvim-treesitter.src.rev; });

  # Sourced mainly from
  # https://github.com/Mic92/dotfiles/blob/8fe93df19d47c8051e569a3a72d72aa6fbf66269/home-manager/modules/neovim/default.nix#L17
  pre = pkgs.writeShellScript "nvim-pre" ''
    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}
    NVIM_APPNAME=${configDir}
    export NVIM_APPNAME
    if [ -d "$XDG_CONFIG_HOME/$NVIM_APPNAME" ]; then
      echo "${treesitter-grammars.rev}" > "$XDG_CONFIG_HOME/$NVIM_APPNAME/treesitter-rev"
      mkdir -p "$XDG_DATA_HOME/$NVIM_APPNAME/site"
      ln -sfT "${treesitter-grammars}" "$XDG_DATA_HOME/$NVIM_APPNAME/site/parser"
      mkdir -p "$XDG_DATA_HOME/$NVIM_APPNAME/lib/"
      ln -sfT "${pkgs.vimPlugins.telescope-fzf-native-nvim}/build/libfzf.so" "$XDG_DATA_HOME/$NVIM_APPNAME/lib/libfzf.so"

      if [[ -f $XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json ]]; then
        if ! grep -q "${treesitter-grammars.rev}" "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"; then
          ${pkgs.neovim}/bin/nvim --headless "+Lazy! update" +qa
        fi
      fi
    fi
  '';

  vscode_cpptools = pkgs.vscode-extensions.ms-vscode.cpptools;
  vscode_cpptools_path =
    "${vscode_cpptools}/share/vscode/extensions/${vscode_cpptools.vscodeExtPublisher}.${vscode_cpptools.vscodeExtName}";

  vscode_lldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;
  vscode_lldb_path =
    "${vscode_lldb}/share/vscode/extensions/${vscode_lldb.vscodeExtPublisher}.${vscode_lldb.vscodeExtName}";

in lib.internal.simpleModule inputs "astronvim" {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [ nord-nvim vim-tmux-navigator ];
    extraWrapperArgs = [
      "--set-default"
      "NVIM_APPNAME"
      "${configDir}"
      "--set-default"
      "OpenDebugAD7_PATH"
      "${vscode_cpptools_path}/debugAdapters/bin/OpenDebugAD7"
      "--set-default"
      "codelldb_PATH"
      "${vscode_lldb_path}/adapter/codelldb"
      "--run"
      "${pre}"
      "--prefix"
      "PATH"
      ":"
      "${lspEnv}/bin"
    ];
  };

  xdg.configFile = {
    # "${configDir}" = {
    #   recursive = true;
    #   source = ./astronvim;
    #   # source = pkgs.fetchFromGitHub {
    #   #   owner = "AstroNvim";
    #   #   repo = "template";
    #   #   rev = "20450d8a65a74be39d2c92bc8689b1acccf2cffe";
    #   #   sha256 = "0ljz7v64gh6vak36wx4409ipi86w3bkr53vzpgijcnvhpva0581z";
    #   # };
    # };
    # "${configDir}/lua/plugins" = {
    #   recursive = true;
    #   source = ./lua/plugins;
    # };
  };

}
