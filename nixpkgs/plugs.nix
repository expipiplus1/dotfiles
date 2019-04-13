{ pkgs, neovim-unconfigured, extraAttrs ? {}, useHIE ? true }:


let
  inherit (pkgs.stdenv) mkDerivation;
  inherit (pkgs) fetchFromGitHub;

  vimPlugin = { name, version, src, postPatch ? "", patches ? [], patchPhase ? "", postPostInstall ? ""}: mkDerivation ({
    inherit name version src patches postPatch patchPhase;
    forceShare= [ "man" "info" ];
    buildPhase = "true";
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      mv * "$out"
      runHook postInstall
      runHook postPostInstall
    '';
    inherit postInstall;
    inherit postPostInstall;
  } // extraAttrs);

  postInstall = ''
    # From vimHelpTags in nixpkgs
    if [ -d "$out/doc" ]; then
      ${neovim-unconfigured}/bin/nvim -N -u NONE -i NONE -n -E -s -c "helptags $out/doc" +quit! || (echo "docs to build failed" && false)
    fi
  '';

  plugs = {
"base16-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "base16-vim-${version}";
  version = "2016-06-25";
  src = fetchFromGitHub {
    owner = "expipiplus1";
    repo = "base16-vim";
    rev = "9daeb991ee51977c3deea4b45846abfab34e9439";
    sha256 = "0n9pcpam15vrnjdl3ghlsr02kldwzi4dlb1w2mwfi57fp65akbnd";
  };
};



# "ctrlp.vim" = {fetchFromGitHub}: vimPlugin rec {
#   name = "ctrlp.vim-${version}";
#   version = "2018-02-20";
#   src = fetchFromGitHub {
#     owner = "ctrlpvim";
#     repo = "ctrlp.vim";
#     rev = "c13c1249fd3bf99c44eb80dfabd7eb7ea0fe09bd";
#     sha256 = "1x5ykqx9g1hxi7fk7cg9hnh9778fpr65bkinbykqc306dbnrdy4g";
#   };
# };

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

"ncm2" = {fetchFromGitHub}: vimPlugin rec {
  name = "ncm2-${version}";
  version = "2019-04-10";
  src = fetchFromGitHub {
    owner = "ncm2";
    repo = "ncm2";
    rev = "e5a7976ad175251a96c537488d2d9557fafdcc8b";
    sha256 = "0jdhbv56vg53vy5yd4322pjyqaidjj0jdbn1ykvi4scci26rzq35";
  };
};

"deoplete-clang2" = {lessWrappedClang}: vimPlugin rec {
  name = "deoplete-clang2-${version}";
  version = "2019-02-27";
  src = fetchFromGitHub {
    owner = "tweekmonster";
    repo = "deoplete-clang2";
    rev = "338f28b077aa0493707e5fa0a2f5bfab46fa5c16";
    sha256 = "1bh7gygmjw9qyny1dhi1hkkc1agsw3yzf3mi68hfknl1falpxizb";
  };
  patchPhase = ''
    substituteInPlace rplugin/python3/deoplete/sources/deoplete_clang2.py \
      --replace "'deoplete#sources#clang#executable', 'clang')"  \
                "'deoplete#sources#clang#executable', '${lessWrappedClang}/bin/clang')"
  '';
};

"fzf" = {}: vimPlugin rec {
  name = "fzf-${version}";
  version = "2019-03-31";
  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf";
    rev = "ff951341c993ed84ad65344e496e122ee3dddf67";
    sha256 = "0pwpr4fpw56yzzkcabzzgbgwraaxmp7xzzmap7w1xsrkbj7dl2xl";
  };
};

"fzf.vim" = {}: vimPlugin rec {
  name = "fzf.vim-${version}";
  version = "2019-02-22";
  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf.vim";
    rev = "b31512e2a2d062ee4b6eb38864594c83f1ad2c2f";
    sha256 = "18wqg6czxwbbydssq6azqcl4llb5lf4phivdas4nqnlgg9hnp5ga";
  };
};

"gist-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "gist-vim-${version}";
  version = "2018-11-09";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "gist-vim";
    rev = "3abf2444bb6a7744a64b4a2c2b02d6761a7de072";
    sha256 = "197j6bhyfggxka9mycyk3mr6sawf7rnaz74csk47d2qlkfs4zf0v";
  };
};

"haskell-vim" = {}: vimPlugin rec {
  name = "haskell-vim-${version}";
  version = "2018-05-22";
  src = fetchFromGitHub {
    owner = "neovimhaskell";
    repo = "haskell-vim";
    rev = "b1ac46807835423c4a4dd063df6d5b613d89c731";
    sha256 = "1vqj3r2v8skffywwgv4093ww7fm540437j5qz7n8q8787bs5w0br";
  };
  patches = [
    # plug-patches/no-space-indent.patch
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
  version = "2019-02-22";
  src = fetchFromGitHub {
    owner = "thirtythreeforty";
    repo = "lessspace.vim";
    rev = "8e6eaa7f3748263c04b1817e5608fe59e554de96";
    sha256 = "0vf7m94fig0s1yy6ybn1pb8fxjxqzncf9ya576m6ay30q8pg7yw1";
  };
};

"lightline.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "lightline.vim-${version}";
  version = "2019-01-19";
  src = fetchFromGitHub {
    owner = "itchyny";
    repo = "lightline.vim";
    rev = "83ae633be323a7fb5baf77e493232cf3358d02bf";
    sha256 = "1y0iwz3wwcds4b2cll893l17i14ih5dwq1njxjbq9sd0694dadz7";
  };
};

"neco-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "neco-vim-${version}";
  version = "2018-10-30";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neco-vim";
    rev = "4c0203b44f8daa7e2f72e2514488d637e8a766a4";
    sha256 = "03v3h2ks6y9pl960lnvzxlfhnn6l2pcn6d6012znw2wqpralrjq2";
  };
};

"neosnippet-snippets" = {fetchFromGitHub}: vimPlugin rec {
  name = "neosnippet-snippets-${version}";
  version = "2019-03-16";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet-snippets";
    rev = "38024eceb05df57c1a3dbf64079f1120f51deb3c";
    sha256 = "16ppys1hvxbh1wivz3z0yyhd77l277lkp6xnsp2q1nwk70cwsag3";
  };
};

"neosnippet.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "neosnippet.vim-${version}";
  version = "2019-04-11";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet.vim";
    rev = "3d3362622ef10deedaea8e026054064bf62aeb33";
    sha256 = "02kvc85yibp1m5b6024z42s94z015czmwhdn7v2glpynj67qv4av";
  };
};

"neovim-fuzzy" = {fetchFromGitHub}: vimPlugin rec {
  name = "neovim-fuzzy-${version}";
  version = "2018-11-15";
  src = fetchFromGitHub {
    owner = "cloudhead";
    repo = "neovim-fuzzy";
    rev = "c177209678477d091ee4576e231c5b80b44514d0";
    sha256 = "069phpy1p8dindi6whddsb9x5zyw1adzsnv7br7q955hf6x9bxxj";
  };
};

"open-browser.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "open-browser-github.vim-${version}";
  version = "2018-11-30";
  src = fetchFromGitHub {
    owner = "tyru";
    repo = "open-browser.vim";
    rev = "b900ff9d39bb36891704bd0fe76737ee3a7ac2b9";
    sha256 = "1sws0pzm13cgl7mf6938xjmh23hk02agf23zfx5rdb4d2lcn4ir3";
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
  version = "2018-11-25";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-abolish";
    rev = "b95463a1cffd8fc9aff2a1ff0ae9327944948699";
    sha256 = "1cvhylz6hgvl63zhlrxqrjqqp07pm29i436xv33dzzhdp8dcj1mp";
  };
};

"vim-clang-format" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-clang-format-${version}";
  version = "2019-03-15";
  src = fetchFromGitHub {
    owner = "rhysd";
    repo = "vim-clang-format";
    rev = "e73d5bc35ac7c86174e6b8ad755c9bde351dbfa9";
    sha256 = "15zxkz5i857b2cxa2glq9r1jsryli798h5hgw8pi4sjhrdladdn2";
  };
};

"vim-commentary" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-commentary-${version}";
  version = "2018-07-27";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-commentary";
    rev = "141d9d32a9fb58fe474fcc89cd7221eb2dd57b3a";
    sha256 = "0nncs32ayfhr557aiynq7b0sc7rxqwv7xanram53x1wvmfy14zf0";
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

"vim-easy-align" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-easy-align-${version}";
  version = "2017-06-03";
  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "vim-easy-align";
    rev = "1cd724dc239c3a0f7a12e0fac85945cc3dbe07b0";
    sha256 = "16yis2wlgi8v0h04hiqmnkm9qrby4kbc2fvkw4szfsbg5m3qx0fc";
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
  version = "2019-04-05";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-fugitive";
    rev = "60eac8c97457af5a96eb06ad4b564e4c813d806e";
    sha256 = "1hqz6hbnvazwq7ngffg638w9qf0b3a0y2wl34ddp5ffkjzxjhr8l";
  };
};

"groovy.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "groovy.vim-${version}";
  version = "2016-01-25";
  src = fetchFromGitHub {
    owner = "modille";
    repo = "groovy.vim";
    rev = "392419dafb8a2f0a93f605ba5b1e90ba48f1644d";
    sha256 = "1dmwas3jc00makldvzrmzsi3xdc1rkzsm61sfxn64g4jy3nnjmfq";
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
  version = "2019-03-12";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-markdown";
    rev = "57c58269a2ac89680e7b216c2bcfbb7df1ec5e69";
    sha256 = "0xpgx79sg4qd80z3m1qv7yzz2hg2g3biyl3q16fzhib1rjaiz5h5";
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
  version = "2018-08-27";
  src = fetchFromGitHub {
    owner = "LnL7";
    repo = "vim-nix";
    rev = "be0c6bb409732b79cc86c177ca378b0b334e1efe";
    sha256 = "1ivkwlm6lz43xk1m7aii0bgn2p3225dixck0qyhxw4zxhp2xiz06";
  };
};

"vim-obsession" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-obsession-${version}";
  version = "2018-09-17";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-obsession";
    rev = "95a576210dc4408a4804a0a62a9eae90d701026b";
    sha256 = "04wrwlvdlakn9vrg48y80pcz2jy6kb1zigmjych15s51ay56cswd";
  };
};

"vim-repeat" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-repeat-${version}";
  version = "2018-07-02";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-repeat";
    rev = "43d2678fa59d068c815d8298331c195e850ff5a7";
    sha256 = "0nb20503ka95qbx0mwhhni15drc86gfcd6kg92nf65llrvyfivk0";
  };
};

"vim-rhubarb" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-rhubarb-${version}";
  version = "2019-03-20";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-rhubarb";
    rev = "57a350e6327af0074c4bc0d30b62662dfdb993af";
    sha256 = "1vgcy8xc8v0g5g4h1h6dcl0ggg2rxp2pisxj04w5d78qf8b48njc";
  };
};

"vim-startify" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-startify-${version}";
  version = "2019-04-11";
  src = fetchFromGitHub {
    owner = "mhinz";
    repo = "vim-startify";
    rev = "0a212847827933436d0b139f37b9825e28e3c0a1";
    sha256 = "08si59jvwlgj1i8z1i0ly439ar75ifrnlraa6nw20n3ii6nwzsvh";
  };
  patches = [
    plug-patches/stylish-git-workspace.patch
  ];
};

"vim-stylish-haskell" = {}: vimPlugin rec {
  name = "vim-stylish-haskell-${version}";
  version = "2018-08-30";
  src = fetchFromGitHub {
    owner = "nbouscal";
    repo = "vim-stylish-haskell";
    rev = "0df8a2dd397f232a9ee0e56bc57071ccf29e21bf";
    sha256 = "05f2ms2c914ycxjjd7csga89mpsk3wzyhi56vikg3nd7a8z54gzw";
  };
  patches = [
    plug-patches/stylish-haskell.patch
    # plug-patches/stylish-haskell-pos.patch
    # plug-patches/stylish-haskell-args.patch
  ];
};

"vim-surround" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-surround-${version}";
  version = "2019-03-26";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-surround";
    rev = "ca58a2d886cc18734c90c9665da4775d444b0c04";
    sha256 = "0d4jxp1ahwrwsk277yvkbk76jrhmv3bml83fivlxpj01224kdr2n";
  };
};

"vim-table-mode" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-table-mode-${version}";
  version = "2019-03-22";
  src = fetchFromGitHub {
    owner = "dhruvasagar";
    repo = "vim-table-mode";
    rev = "a40ef26c5cc1806d3faae829fa149506715ce56f";
    sha256 = "0fis0w3xpsg4wfss61vydic6zisg5bdyvb0wcaf5z4fs5sk380x6";
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
  version = "2018-11-19";
  src = fetchFromGitHub {
    owner = "kana";
    repo = "vim-textobj-user";
    rev = "074ce2575543f790290b189860597a3dcac1f79d";
    sha256 = "15wnqkxjjksgn8a7d3lkbf8d97r4w159bajrcf1adpxw8hhli1vc";
  };
};

"vim-tmux-focus-events" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-tmux-focus-events-${version}";
  version = "2019-01-22";
  src = fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "vim-tmux-focus-events";
    rev = "32723c5d778905a2a2e40030990c80c17f456649";
    sha256 = "0symr2xymxxxyplb3pa0zr7whzmwwpw8bz4alkaf65niik7jsnk2";
  };
};

"vim-tmux-navigator" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-tmux-navigator-${version}";
  version = "2019-01-29";
  src = fetchFromGitHub {
    owner = "christoomey";
    repo = "vim-tmux-navigator";
    rev = "4e1a877f51a17a961b8c2a285ee80aebf05ccf42";
    sha256 = "1b8sgbzl4pcpaabqk254n97mjz767ganrmqbsr6rqzz3j9a3s1fv";
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
  version = "2019-03-21";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-unimpaired";
    rev = "e77923053fbce11323194ed04113b8d966be959c";
    sha256 = "1cka410c94wa6mz0pr4m8n9j7s9jhqnw513479pkmzx435ffb6ak";
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
  version = "2019-01-07";
  src = fetchFromGitHub {
    owner = "stephpy";
    repo = "vim-yaml";
    rev = "0da1975ec394154349db744c1996fe2ef8fa5ed0";
    sha256 = "0kvsy6k4snwykpxk49x06jizxqrjjmbhhdcwiyiqy0029n05322l";
  };
};

"vimproc.vim" = {stdenv, fetchFromGitHub, which}: mkDerivation rec {
  name = "vimproc.vim-${version}";
  version = "2019-03-10";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "vimproc.vim";
    rev = "eb5b2b1248ccc8b1b9e84d7658508e38b964d17d";
    sha256 = "0h9na94cg396mldqdasdkv30z67zp5r36794dlhh9j5kblc00x0v";
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
  version = "2018-05-13";
  src = fetchFromGitHub {
    owner = "eagletmt";
    repo = "neco-ghc";
    rev = "682869aca5dd0bde71a09ba952acb59c543adf7d";
    sha256 = "1v7ibi4fp99s4lswz3v0gf4i0h5i5gpj05xpsf4cixwj2zgh206h";
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
  version = "2019-04-10";
  src = fetchFromGitHub {
    owner = "neomake";
    repo = "neomake";
    rev = "9ccc5d6662fb35383fe7fa7ea9e33467d28a0372";
    sha256 = "1j2jr5ilcws1bpbnhch2y6jh6303w305c06rncgawibxyqsxvnmw";
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
      rev = "c33c45dd8384c0a0dfe8e99c558415b5c656d5c8";
      sha256 = "1j5ygf7080d5jr3q0wzfmk7ip47xa93rl13dhcqwgmfccyxrk4g2";
    };
    pkgs_ = pkgs;
    bin =
      let
        # pkgs = (
        #   let
        #     nixpkgs = import pkgs_.path;
        #     rustOverlay = /home/j/src/nixpkgs-mozilla;
        #   in (nixpkgs {
        #     overlays = [
        #       (import (builtins.toPath "${rustOverlay}/rust-overlay.nix"))
        #       (self: super: {
        #         rust = {
        #           rustc = super.rustChannels.stable.rust;
        #           cargo = super.rustChannels.stable.cargo;
        #         };
        #         rustPlatform = super.recurseIntoAttrs (super.makeRustPlatform {
        #           rustc = super.rustChannels.stable.rust;
        #           cargo = super.rustChannels.stable.cargo;
        #         });
        #       })
        #     ];
        #   }));
      in pkgs.rustPlatform.buildRustPackage {
           inherit name src;
           cargoSha256 = "0qz7d31j7kvynswcg5j2sksn8zp654qzy1x6kjy3c13c7g9731cl";
    };
  in vimPlugin rec {
    inherit name version src;
    postPostInstall = ''
      ln -s "${bin}/bin/languageclient" "$out/bin/languageclient"
    '';
  };
};

in plugs
