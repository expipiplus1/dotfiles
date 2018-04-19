{ pkgs, neovim-unconfigured, extraAttrs ? {} }:


let
  useHIE = true;

  inherit (pkgs.stdenv) mkDerivation;
  inherit (pkgs) fetchFromGitHub;

  vimPlugin = { name, version, src, postPatch ? "", patches ? [], patchPhase ? "" }: mkDerivation ({
    inherit name version src patches postPatch patchPhase;
    forceShare= [ "man" "info" ];
    buildPhase = "true";
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      mv * "$out"
      runHook postInstall
    '';
    inherit postInstall;
  } // extraAttrs);

  postInstall = ''
    # From vimHelpTags in nixpkgs
    if [ -d "$out/doc" ]; then
      ${neovim-unconfigured}/bin/nvim -N -u NONE -i NONE -n -E -s -c "helptags $out/doc" +quit! || (echo "docs to build failed" && false)
    fi
  '';

in {
"base16-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "base16-vim-${version}";
  version = "2016-06-25";
  src = fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-vim";
    rev = "9daeb991ee51977c3deea4b45846abfab34e9439";
    sha256 = "0n9pcpam15vrnjdl3ghlsr02kldwzi4dlb1w2mwfi57fp65akbnd";
  };
};


"comfortable-motion.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "comfortable-motion.vim-${version}";
  version = "2018-02-23";
  src = fetchFromGitHub {
    owner = "yuttie";
    repo = "comfortable-motion.vim";
    rev = "e20aeafb07c6184727b29f7674530150f7ab2036";
    sha256 = "13chwy7laxh30464xmdzjhzfcmlcfzy11i8g4a4r11m1cigcjljb";
  };
};

# "deoplete.nvim" = {fetchFromGitHub}: vimPlugin rec {
#   name = "deoplete.nvim-${version}";
#   version = "2018-03-19";
#   src = fetchFromGitHub {
#     owner = "Shougo";
#     repo = "deoplete.nvim";
#     rev = "0df0b9d84ce97426206c7a5aa6f51a2975dedd15";
#     sha256 = "10zki2j5j6lm3rxcn52ndwlx39rqs9p3ayzzyhz9z5f0ivwbglcz";
#   };
# };

"nvim-completion-manager" = {fetchFromGitHub}: vimPlugin rec {
  name = "nvim-completion-manager-${version}";
  version = "2018-04-18";
  src = fetchFromGitHub {
    owner = "roxma";
    repo = "nvim-completion-manager";
    rev = "3ef5ade36e7321aace4e9e22da216202bdcd65f1";
    sha256 = "0vfcnvdcxhs3in4pwcqjb5h3ns7ik53n4xb1h9r94w1gfw00lh1l";
  };
};

"deoplete-clang2" = {lessWrappedClang}: vimPlugin rec {
  name = "deoplete-clang2-${version}";
  version = "2018-01-02";
  src = fetchFromGitHub {
    owner = "tweekmonster";
    repo = "deoplete-clang2";
    rev = "8877dda0a474824977443a112cf0f4fa465e97f6";
    sha256 = "1k8c2ph04fj2c5dqm6ky8jhr8g2srdpafapy102n46nksyyx0yhf";
  };
  patchPhase = ''
    substituteInPlace rplugin/python3/deoplete/sources/deoplete_clang2.py \
      --replace "'deoplete#sources#clang#executable', 'clang')"  \
                "'deoplete#sources#clang#executable', '${lessWrappedClang}/bin/clang')"
  '';
};

"floobits-neovim" = {fetchFromGitHub}: vimPlugin rec {
  name = "floobits-neovim-${version}";
  version = "2017-08-02";
  src = fetchFromGitHub {
    owner = "Floobits";
    repo = "floobits-neovim";
    rev = "9ccd5a8d5d28261b9686717d61a32b756f38f189";
    sha256 = "02njg49qz9bfzggpn7z5c7w1wa1k5hxly66904wizl601fa6c664";
  };
};

"fzf" = {}: vimPlugin rec {
  name = "fzf-${version}";
  version = "2018-04-12";
  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf";
    rev = "f57920ad903105381b02502580be2bb11e4e6714";
    sha256 = "0bfs8qif9xlaxvbmz5rphy1sgdk5iq1id36r5a2bnmr1lyqi4nmr";
  };
};

"fzf.vim" = {}: vimPlugin rec {
  name = "fzf.vim-${version}";
  version = "2018-04-19";
  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf.vim";
    rev = "dc5f9437fcaed9f6896235830246871fdf9c9ba8";
    sha256 = "04v06m347f3b9xrw2fg4gyzzwk29x082j440qlxrp93phcfpgjl0";
  };
};

"gist-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "gist-vim-${version}";
  version = "2016-10-10";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "gist-vim";
    rev = "f0d63579eab7548cf12f979dc52ef5a370ecbe63";
    sha256 = "06nix49j4inxy3rkcv32f4ka89g4crqwfqnrm3b76iwwky8m2p17";
  };
};

"haskell-vim" = {}: vimPlugin rec {
  name = "haskell-vim-${version}";
  version = "2018-04-13";
  src = fetchFromGitHub {
    owner = "neovimhaskell";
    repo = "haskell-vim";
    rev = "e027b314df128979dbd00dd94c9db080db156b5c";
    sha256 = "13dx1ifwa444q8zkwda4qha74xjm4jfhhk9lbgbj9p1mj7gvbl7f";
  };
  patches = [
    plug-patches/no-space-indent.patch
    plug-patches/cabal-module-word.patch
  ];
};

"hlint-refactor-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "hlint-refactor-vim-${version}";
  version = "2015-12-05";
  src = fetchFromGitHub {
    owner = "mpickering";
    repo = "hlint-refactor-vim";
    rev = "fffb044ecef854a82c5c2efda252e09044ba03e0";
    sha256 = "0z8d31arfy9aidg1dwj5msnnx799d9r7njkgh51z695w6ayxn6p8";
  };
};

"hlsl.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "hlsl.vim-${version}";
  version = "2015-02-24";
  src = fetchFromGitHub {
    owner = "beyondmarc";
    repo = "hlsl.vim";
    rev = "f255936d1e37899f46cac92e39bfda1cd36be04b";
    sha256 = "1adlfwxb2fgiksy8s0nz1139m6xj6xksrzsphc4qszwmyy8n6nsp";
  };
};

"lessspace.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "lessspace.vim-${version}";
  version = "2018-03-06";
  src = fetchFromGitHub {
    owner = "thirtythreeforty";
    repo = "lessspace.vim";
    rev = "fd16589b8b0a45a7ed5ce48f24c71fae21950057";
    sha256 = "1kddb2vrvs6km15wwlygz8d2klb53nkbr7xfwx3bpg8r5d4iapa4";
  };
};

"lightline.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "lightline.vim-${version}";
  version = "2018-04-14";
  src = fetchFromGitHub {
    owner = "itchyny";
    repo = "lightline.vim";
    rev = "e54d2ae512c9c081bfff9303cb22ffa94ed48ba3";
    sha256 = "042sfdwj46yv0bmf0cm5vm24j197isc3asdj4ymxzh5d6jy2i5qb";
  };
};

"neco-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "neco-vim-${version}";
  version = "2017-10-01";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neco-vim";
    rev = "f5397c5e800d65a58c56d8f1b1b92686b05f4ca9";
    sha256 = "0yb7ja6qgrazszk4i01cwjj00j9vd43zs2r11b08iy8n10jnzr73";
  };
};

"neosnippet-snippets" = {fetchFromGitHub}: vimPlugin rec {
  name = "neosnippet-snippets-${version}";
  version = "2018-04-15";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet-snippets";
    rev = "f453635c60998071299c3239c3d881f2be0c248e";
    sha256 = "1df6mzk5yjhjlmzgz7lr9aa69a973mzfxmwldqnpi6yjfnmjn04c";
  };
};

"neosnippet.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "neosnippet.vim-${version}";
  version = "2018-03-12";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet.vim";
    rev = "8cf286e3bf7a5fc859f4c5f1bef52c351f24fefa";
    sha256 = "15mxckg5s9pjfm7xkhs4awx0vpmwdwwifqrvrh1r4mbia39pk6ry";
  };
};

"neovim-fuzzy" = {fetchFromGitHub}: vimPlugin rec {
  name = "neovim-fuzzy-${version}";
  version = "2017-12-03";
  src = fetchFromGitHub {
    owner = "cloudhead";
    repo = "neovim-fuzzy";
    rev = "ecb394cc3ca26d120d20ff31b5b2be9ea3f783b6";
    sha256 = "1lwhq3wwj7zw9z50i0vf7yv4jsfh5b3gq8jpjq1i823daxfvj87y";
  };
};

"open-browser.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "open-browser-github.vim-${version}";
  version = "2018-03-11";
  src = fetchFromGitHub {
    owner = "tyru";
    repo = "open-browser.vim";
    rev = "43b08d6642f26af5a875b0d0bdb3aa9a6d12e7eb";
    sha256 = "162dv172n16jpjr812d561yyj9rz9xn4qrfx18wlpyixj3qf2bda";
  };
};


"open-browser-github.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "open-browser-github.vim-${version}";
  version = "2018-03-15";
  src = fetchFromGitHub {
    owner = "tyru";
    repo = "open-browser-github.vim";
    rev = "6f63e9c8b9482858af12c2dc60f6df2854e57f28";
    sha256 = "06wvj6sqqzf52ng0k0p9g8wnlrljnia6h4d65681plqyxakbvi2w";
  };
};

"prev_indent" = {fetchFromGitHub}: vimPlugin rec {
  name = "prev_indent-${version}";
  version = "2014-03-08";
  src = fetchFromGitHub {
    owner = "vim-scripts";
    repo = "prev_indent";
    rev = "79e9b1b9a6895bfd15463c45595ca599987a4b23";
    sha256 = "03xqdwfkc7a84742ldsggi7ix99c7dhpmg6j13gkasyfk487ryh6";
  };
};

"tabular" = {fetchFromGitHub}: vimPlugin rec {
  name = "tabular-${version}";
  version = "2016-05-04";
  src = fetchFromGitHub {
    owner = "godlygeek";
    repo = "tabular";
    rev = "00e1e7fcdbc6d753e0bc8043e0d2546fa81bf367";
    sha256 = "185jpisk9hamcwb6aiavdzjdbbigzdra8f4mgs98r9cm9j448xkz";
  };
};

"terra.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "terra.vim-${version}";
  version = "2013-08-11";
  src = fetchFromGitHub {
    owner = "vim-scripts";
    repo = "terra.vim";
    rev = "58f80c9c60b085c5ec1a3a6038d56509638ab3e1";
    sha256 = "0nvj412rixy65x6133cdpvk1s84dz3nd0f5gykykfhkwh24pjd7j";
  };
};

"unite-haddock" = {fetchFromGitHub}: vimPlugin rec {
  name = "unite-haddock-${version}";
  version = "2014-05-10";
  src = fetchFromGitHub {
    owner = "eagletmt";
    repo = "unite-haddock";
    rev = "a2ed7259c83b405b275148f1d24d34d5a30e7ab0";
    sha256 = "054fn7iyq9sry02lrj68aajwj8jp53nidfmyhi84cxhjxif7nr54";
  };
};

"vim-abolish" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-abolish-${version}";
  version = "2017-03-10";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-abolish";
    rev = "b6a8b49e2173ba5a1b34d00e68e0ed8addac3ebd";
    sha256 = "0i9q3l7r5p8mk4in3c1j4x0jbln7ir9lg1cqjxci0chjjzfzc53m";
  };
};

"vim-clang-format" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-clang-format-${version}";
  version = "2018-02-01";
  src = fetchFromGitHub {
    owner = "rhysd";
    repo = "vim-clang-format";
    rev = "8ff1660a1e9f856479fffe693743521f4f3068cb";
    sha256 = "1g9vs6cg7irmwqa1lz6i7xbq50svykhvax12vx7cpf2bxs8jfp3n";
  };
};

"vim-commentary" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-commentary-${version}";
  version = "2018-04-17";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-commentary";
    rev = "54e5676988e6eeaa05b41730b6b056026ad0ef13";
    sha256 = "1ww4a9f2jxjl81rmwh09z3bc58qjnws8097xykliacl1ka602hf1";
  };
};

"vim-diminactive" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-diminactive-${version}";
  version = "2017-08-27";
  src = fetchFromGitHub {
    owner = "blueyed";
    repo = "vim-diminactive";
    rev = "6f2e14e6ff6a038285937c378ec3685e6ff7ee36";
    sha256 = "14jf5hh3v2f5wb10v09ygx15pxbwziv20pwv0fqkakxwf0vqwd50";
  };
};

"vim-easytags" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-easytags-${version}";
  version = "2015-07-01";
  src = fetchFromGitHub {
    owner = "xolox";
    repo = "vim-easytags";
    rev = "72a8753b5d0a951e547c51b13633f680a95b5483";
    sha256 = "0i8ha1fa5d860b1mi0xp8kwsgb0b9vbzcg1bldzv6s5xd9yyi12i";
  };
};

"vim-fugitive" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-fugitive-${version}";
  version = "2018-04-15";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-fugitive";
    rev = "40d78f07dee2ffab68abb9d6d1a9e27843df0fe0";
    sha256 = "16fh3n8sr57cfhfpilqhz9f3svhj4swa9yqjf4wicbw9zn40hrir";
  };
};

"vim-hare" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-hare-${version}";
  version = "2016-04-20";
  src = fetchFromGitHub {
    owner = "glittershark";
    repo = "vim-hare";
    rev = "63d8e98a84455e48ba00261366e6e08a2dee1284";
    sha256 = "01hkpkfsi4x4cb4lk8zbsh7hj2cawszf2dv63iqnkrw1mhd0nhhl";
  };
};

"vim-hoogle" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-hoogle-${version}";
  version = "2018-03-04";
  src = fetchFromGitHub {
    owner = "Twinside";
    repo = "vim-hoogle";
    rev = "871d104c92e33cb238506f2805f1652561978cc8";
    sha256 = "17qvi57g72ijgk7nczczli3kcphvdf625fzqbqcmqpsawgvfd07n";
  };
};

"vim-markdown" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-markdown-${version}";
  version = "2018-02-04";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-markdown";
    rev = "e2d7fcd682a461a3951e8b5067cc8a0083e75e35";
    sha256 = "1g1h3c8i4949kfh2vpxx00hryv0cca1kh44i4g1g6yxa6jdrpg1j";
  };
  patches = [ ./plug-patches/vim-markdown-no-codeblock.patch ];
};

"vim-misc" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-misc-${version}";
  version = "2015-05-21";
  src = fetchFromGitHub {
    owner = "xolox";
    repo = "vim-misc";
    rev = "3e6b8fb6f03f13434543ce1f5d24f6a5d3f34f0b";
    sha256 = "0rd9788dyfc58py50xbiaz5j7nphyvf3rpp3yal7yq2dhf0awwfi";
  };
};

"vim-nix" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-nix-${version}";
  version = "2018-04-15";
  src = fetchFromGitHub {
    owner = "LnL7";
    repo = "vim-nix";
    rev = "bf5779180bf0e3cb6c967f87d6262a976e055e32";
    sha256 = "023c932vybycj8zasvgvp7xhp42i2iy26msjgjsgzfwmdf5w877y";
  };
};

"vim-obsession" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-obsession-${version}";
  version = "2018-03-01";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-obsession";
    rev = "d2f78ce466186839b1838c7e85115f96d051c7a5";
    sha256 = "1027iln716cmycvl4zgkqp0ybzdy7r1bl32x5l776yyjby1ssmqb";
  };
};

"vim-repeat" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-repeat-${version}";
  version = "2018-01-30";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-repeat";
    rev = "8106e142dfdc278ff3eaaadd7b362ad7949d4357";
    sha256 = "1q0bmqxi1kqxq7g8l0qj7y93g9rqffwc3fbmhpj3chx2kswhd5hc";
  };
};

"vim-rhubarb" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-rhubarb-${version}";
  version = "2017-06-28";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-rhubarb";
    rev = "6caad2b61afcc1b7c476b0ae3dea9ee5f2b1d14a";
    sha256 = "1bmc5j9056bgdhyhvylbd93jkp1k9067mv3af6skzh0r77rx1a0g";
  };
};

"vim-startify" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-startify-${version}";
  version = "2018-04-10";
  src = fetchFromGitHub {
    owner = "mhinz";
    repo = "vim-startify";
    rev = "532f3db6be8c6e123abb3f6523c419b6b19436da";
    sha256 = "19inxsafsivdwgdvw59x3dbx65xkb09q0k2p66q4n57fj60bajmb";
  };
  patches = [
    plug-patches/stylish-git-workspace.patch
  ];
};

"vim-stylish-haskell" = {}: vimPlugin rec {
  name = "vim-stylish-haskell-${version}";
  version = "2015-05-10";
  src = fetchFromGitHub {
    owner = "nbouscal";
    repo = "vim-stylish-haskell";
    rev = "c664376ba814de3f87cb7641f90b2c6a9dd53671";
    sha256 = "1xm5ark2mwphznv3xsyzgcldnr52i5jzk1pfqdh0080j07aama8j";
  };
  patches = [
    plug-patches/stylish-haskell.patch
    plug-patches/stylish-haskell-pos.patch
    plug-patches/stylish-haskell-args.patch
  ];
};

"vim-surround" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-surround-${version}";
  version = "2016-06-01";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-surround";
    rev = "e49d6c2459e0f5569ff2d533b4df995dd7f98313";
    sha256 = "1v0q2f1n8ngbja3wpjvqp2jh89pb5ij731qmm18k41nhgz6hhm46";
  };
};

"vim-table-mode" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-table-mode-${version}";
  version = "2018-03-22";
  src = fetchFromGitHub {
    owner = "dhruvasagar";
    repo = "vim-table-mode";
    rev = "e646bee5c45201b52f8f879eddf84b5c2e360e98";
    sha256 = "1kaszrik5mqrvavl0lzfy9i0r3b2vf1jmjxp23azy0jfanflrxwa";
  };
};

"vim-textobj-comment" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-textobj-comment-${version}";
  version = "2014-04-11";
  src = fetchFromGitHub {
    owner = "glts";
    repo = "vim-textobj-comment";
    rev = "58ae4571b76a5bf74850698f23d235eef991dd4b";
    sha256 = "00wc14chwjfx95gl3yzbxm1ajx88zpzqz0ckl7xvd7gvkrf0mx04";
  };
};

"vim-textobj-function" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-textobj-function-${version}";
  version = "2014-05-03";
  src = fetchFromGitHub {
    owner = "kana";
    repo = "vim-textobj-function";
    rev = "adb50f38499b1f558cbd58845e3e91117e4538cf";
    sha256 = "0cwl102si9zhhhpg6c0fjnyq35v6bl5f34p2s7b47isxdn0qvris";
  };
};

"vim-textobj-haskell" = {}: vimPlugin rec {
  name = "vim-textobj-haskell-${version}";
  version = "2014-10-27";
  src = fetchFromGitHub {
    owner = "gibiansky";
    repo = "vim-textobj-haskell";
    rev = "ca656e98ea31e201f5bc543909398a6c8bb5d537";
    sha256 = "096pjjl3ngw0hsh59j2x6pdrpqvp657rcxfyl9kw13ndqyd867xs";
  };
  patches = [
    plug-patches/vim-textobj-haskell-typesig.patch
    plug-patches/vim-textobj-haskell-end.patch
  ];
};

"vim-textobj-user" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-textobj-user-${version}";
  version = "2017-09-28";
  src = fetchFromGitHub {
    owner = "kana";
    repo = "vim-textobj-user";
    rev = "e231b65797b5765b3ee862d71077e9bd56f3ca3e";
    sha256 = "0zsgr2cn8s42d7jllnxw2cvqkl27lc921d1mkph7ny7jgnghaay9";
  };
};

"vim-tmux-focus-events" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-tmux-focus-events-${version}";
  version = "2018-03-03";
  src = fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "vim-tmux-focus-events";
    rev = "48595bdef7d25087111c86cd3c6ca34bc60909c7";
    sha256 = "0285158q69z38pjg0pzal1y6bx0zd1crv077j2siq0if4fxrf3jl";
  };
};

"vim-tmux-navigator" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-tmux-navigator-${version}";
  version = "2017-07-07";
  src = fetchFromGitHub {
    owner = "christoomey";
    repo = "vim-tmux-navigator";
    rev = "d724094e7128acd7375cc758008f1e1688130877";
    sha256 = "1n0n26lx056a0f8nmzbjpf8a48971g4d0fzv8xmq8yy505gbq9iw";
  };
};

"vim-togglelist" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-togglelist-${version}";
  version = "2013-04-07";
  src = fetchFromGitHub {
    owner = "milkypostman";
    repo = "vim-togglelist";
    rev = "cafedc49860950200f28f2e1d95ab6a87b79d113";
    sha256 = "17y4ply2irz81gjv5hb51dy7wzv3l3sq6qaska31lswd5dgh1ifg";
  };
};

"vim-unimpaired" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-unimpaired-${version}";
  version = "2018-03-01";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-unimpaired";
    rev = "c77939c4aff30b2ed68deb1752400ec15f17c3a2";
    sha256 = "0qd9as008r2vycls48bfb163rp7dddw7l495xn4l1gl00sh79cxy";
  };
};

"vim-visual-increment" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-visual-increment-${version}";
  version = "2015-07-02";
  src = fetchFromGitHub {
    owner = "triglav";
    repo = "vim-visual-increment";
    rev = "e50e8f7c062cec759f665278eb58535df1611a23";
    sha256 = "1gd6mxp9y80wf7nxcm02104l54gqz5k3dgv1h98jl9a7q9swb8y6";
  };
};

"vim-yaml" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-yaml-${version}";
  version = "2018-01-16";
  src = fetchFromGitHub {
    owner = "stephpy";
    repo = "vim-yaml";
    rev = "05e225d5b3c7a885bb79c57d6500d76af631bf43";
    sha256 = "1bda4fs5b90fz2phwj2pkbk7wv1v68327a18isb54ksd7db2cwvc";
  };
};

"vimproc.vim" = {stdenv, fetchFromGitHub, which}: mkDerivation rec {
  name = "vimproc.vim-${version}";
  version = "2018-01-07";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "vimproc.vim";
    rev = "2300224d366642f4f8d6f88861535d4ccbe20143";
    sha256 = "0b8ljqnix8bs667bpymg3s0g5f49fnphgddl6196dj6jvdfn1xia";
  };
  buildInputs = [ which ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out/
    runHook postInstall
  '';
  inherit postInstall;
  patches = [
    plug-patches/vimproc-dll-loc.patch
  ];
};

"webapi-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "webapi-vim-${version}";
  version = "2018-03-14";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "webapi-vim";
    rev = "252250381a9509257bfb06b9f95441e41e3e23b5";
    sha256 = "0g37d1i6rxsj6f31g9jy2bhr8ng3jwmnvqqcmw19vbql4v56zq6a";
  };
};

"vim-prototxt" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-prototxt-${version}";
  version = "2016-11-12";
  src = fetchFromGitHub {
    owner = "chiphogg";
    repo = "vim-prototxt";
    rev = "b2b5e1c2f67a45eee5a4a3d791053e6cb6757583";
    sha256 = "12xzfjks3qgz39agi5fcmy3g41k4wa2l716nnp677xv9q5jda2nk";
  };
};
} // pkgs.lib.optionalAttrs (!useHIE) {

"neco-ghc" = {}: vimPlugin rec {
  name = "neco-ghc-${version}";
  version = "2017-08-17";
  src = fetchFromGitHub {
    owner = "eagletmt";
    repo = "neco-ghc";
    rev = "faa033c05e6a6470d3d780e3931b4c9c72042009";
    sha256 = "01l5n4x94sb6bhjhjx2sibs8gm3zla7hb6szdfgbdmdf7jlzazak";
  };
  patches = [
    plug-patches/streamline-neco-ghc.patch
  ];
};

"vim-hdevtools" = {}: vimPlugin rec {
  name = "vim-hdevtools-${version}";
  version = "2016-07-08";
  src = fetchFromGitHub {
    owner = "parsonsmatt";
    repo = "vim-hdevtools";
    rev = "43ec8a167b3c69500f291a0e58a6779a3898de26";
    sha256 = "198qabn6r5hvjbj9dlb7avzywhh3d5zghgdpli2x119ky1cgkmvq";
  };
  patches = [
    ./plug-patches/hdevtools.patch
  ];
};

"neomake" = {lessWrappedClang, clang-tools}: vimPlugin rec {
  name = "neomake-${version}";
  version = "2018-04-18";
  src = fetchFromGitHub {
    owner = "neomake";
    repo = "neomake";
    rev = "51010403903ff7dd6497d46b958924f1270aaae4";
    sha256 = "021lw22p3f5wwk7xi4dphlbpmyy9rql0f6ndzj546kbby6nd0r53";
  };
  patches = [
    plug-patches/always-quickfix.patch
    plug-patches/neomake-hdevtools.patch
    plug-patches/neomake-explicit-clang.patch
    plug-patches/neomake-no-stack.patch
    plug-patches/neomake-mu.patch
  ];
  postPatch = ''
    substituteInPlace autoload/neomake/makers/ft/cpp.vim \
      --replace "executable('clang++')" "executable('${lessWrappedClang}/bin/clang++')" \
      --replace "maker.exe = 'clang++'" "maker.exe = '${lessWrappedClang}/bin/clang++'"
    substituteInPlace autoload/neomake/makers/ft/c.vim \
      --replace "executable('clang')" "executable('${lessWrappedClang}/bin/clang')" \
      --replace "'exe': 'clang'" "'exe': '${lessWrappedClang}/bin/clang'" \
      --replace "'exe': 'clang-tidy'" "'exe': '${clang-tools}/bin/clang-tidy'" \
      --replace "'exe': 'clang-check'" "'exe': '${clang-tools}/bin/clang-check'" \
  '';
};


} // pkgs.lib.optionalAttrs useHIE {
"LanguageClient-neovim" = {}:
  let
    version = "2018-01-07";
    name = "LanguageClient-neovim-${version}";
    src = fetchFromGitHub {
      owner = "autozimu";
      repo = "LanguageClient-neovim";
      rev = "61657c98d10c526194f56e31bbb0cf4d40b42d86";
      sha256 = "1pk8s1kwz50v4w5j8ha50mgp2ki5lsjh2bc6l61kx5nw4lh6xjdv";
    };
    bin = pkgs.rustPlatform.buildRustPackage {
      inherit name src;
      cargoSha256 = "1d78nxl2bihi385yb7wcps1fjb4sbq77jc9awimzyq6jzsah6p2g";
    };
  in vimPlugin rec {
    inherit name version src;
    postPatch = ''
      substituteInPlace plugin/LanguageClient.vim \
        --replace "let l:command = [s:root . '/bin/languageclient']" "let l:command = ['${bin}/bin/languageclient']"
    '';
  };
}
