{ config, pkgs, ... }:

let
  appendPatches = patches: drv:
    drv.overrideAttrs (old: { patches = old.patches or [ ] ++ patches; });

in {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      (base16-vim.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "expipiplus1";
          repo = "base16-vim";
          rev = "9daeb991ee51977c3deea4b45846abfab34e9439";
          sha256 = "0n9pcpam15vrnjdl3ghlsr02kldwzi4dlb1w2mwfi57fp65akbnd";
        };
      }))
      fzf-vim
      ncm2
      ncm2-path
      ncm2-bufword
      tmux-complete-vim
      gist-vim
      (appendPatches [ ../../../nixpkgs/plug-patches/cabal-module-word.patch ]
        haskell-vim)
      hlint-refactor-vim
      lessspace-vim
      lightline-vim
      neovim-fuzzy
      open-browser-vim
      open-browser-github-vim
      prev_indent
      vim-abolish
      vim-commentary
      vim-diminactive
      vim-easy-align
      vim-fugitive
      vim-rhubarb
      vim-markdown
      vim-nix
      vim-repeat
      vim-startify
      vim-surround
      vim-table-mode
      vim-textobj-function
      (appendPatches [
        ../../../nixpkgs/plug-patches/vim-textobj-haskell-typesig.patch
        ../../../nixpkgs/plug-patches/vim-textobj-haskell-end.patch
      ] vim-textobj-haskell)
      vim-textobj-user
      vim-tmux-focus-events
      vim-tmux-navigator
      vim-togglelist
      vim-unimpaired
      vim-visual-increment
      vim-yaml
    ];
    extraConfig = builtins.readFile ./init.vim;
  };
}