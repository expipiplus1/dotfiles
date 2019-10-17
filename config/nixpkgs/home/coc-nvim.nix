{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ coc-nvim ];
    withNodeJs = true;
  };

  xdg.configFile."nvim/coc-settings.json".source = pkgs.writeTextFile {
    name = "coc-settings.json";
    text = builtins.toJSON {
      languageserver = {
        haskell = {
          command = "hie-wrapper";
          rootPatterns =
            [ ".stack.yaml" "cabal.config" "cabal.project" "package.yaml" ];
          requireRootPattern = true;
          filetypes = [ "hs" "lhs" "haskell" ];
          initializationOptions = {
            languageServerHaskell = { hlintOn = true; };
          };
        };
      };
    };
  };
}
