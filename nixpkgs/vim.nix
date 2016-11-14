{pkgs ? import <nixpkgs> {}}:

with pkgs;
with pkgs.lib.strings;
with pkgs.lib.attrsets;
rec {
  makeRtpFile = plugins: writeTextFile { 
    name = "rtp.vim";
    text = let f = s: "set rtp+=${s}";
           in concatMapStringsSep "\n" f plugins;
  };

  rtpFile = 
    let plugins = mapAttrs (n: p: pkgs.callPackage p {}) (import ./plugs.nix);
    in makeRtpFile (attrValues plugins);
}
