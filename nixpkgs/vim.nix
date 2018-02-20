{pkgs ? import <nixpkgs> {}, neovim-unconfigured}:

with pkgs;
with pkgs.lib.strings;
with pkgs.lib.attrsets;
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

  rtpFile =
    let plugins = mapAttrs
                    (n: p: pkgs.callPackage p {})
                    (import ./plugs.nix {inherit pkgs neovim-unconfigured;});
    in makeRtpFile (attrValues plugins);
}
