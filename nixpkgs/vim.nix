{ pkgs ? import <nixpkgs> {}, neovim-unconfigured
, cygwin ? false
}:

with pkgs;
with pkgs.lib.strings;
with pkgs.lib.attrsets;
with pkgs.lib.lists;
rec {
  makeRtpFile = plugins: writeTextFile {
    name = "rtp.vim";
    text = ''
      let s:oldrtp = &rtp
      set rtp=~/.config/nvim
      ${concatMapStringsSep "\n" (s: "set rtp+=${s}") plugins}
      for p in split(s:oldrtp, ",")
        exe 'set rtp+=' . expand(p)
      endfor
      ${concatMapStringsSep "\n" (s: "set rtp+=${s}/after") plugins}
    '';
  };

  plugs = import ./plugs.nix ({
    inherit pkgs neovim-unconfigured;
  } // optionalAttrs cygwin {
    extraAttrs = {
      dontPatchShebangs = true;
    };
  });

  cygwinDisallowedPlugs =
    let fs = [
          "vimproc.vim"
          "LanguageClient-neovim"
          "deoplete-clang2"
        ];
        plugNames = attrNames plugs;
    in assert (all (f: elem f plugNames) fs); fs;

  filteredPlugs = filterAttrs (n: v: cygwin -> !(elem n cygwinDisallowedPlugs)) plugs;

  rtpFile =
    let plugins = mapAttrs
                    (n: p: pkgs.callPackage p {})
                    filteredPlugs;
    in makeRtpFile (attrValues plugins);
}
