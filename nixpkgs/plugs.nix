let
  vimPlugin = { name, version, src }: src;
  pluginAttrs = attrs: {
    buildPhase = "true";
    installPhase = ''
      mkdir -p "$out"
      mv * "$out"
    '';
  } // attrs;
in {
"Align" = {fetchFromGitHub}: vimPlugin rec {
  name = "Align-${version}";
  version = "2012-08-07";
  src = fetchFromGitHub {
    owner = "vim-scripts";
    repo = "Align";
    rev = "787662fe90cd057942bc5b682fd70c87e1a9dd77";
    sha256 = "0acacr572kfh7jvavbw61q5pkwrpi1albgancma063rpax1pddgp";
  };
};

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

"deoplete.nvim" = {fetchFromGitHub}: vimPlugin rec {
  name = "deoplete.nvim-${version}";
  version = "2017-04-18";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "deoplete.nvim";
    rev = "f583f80f0c62f4258bfddff35cdc93b872a6e740";
    sha256 = "0kl73qw1gk6dfr1gm9bh6cyrl2f2cr1nm43bny99k781vsw8j08r";
  };
};

"floobits-neovim" = {fetchFromGitHub}: vimPlugin rec {
  name = "floobits-neovim-${version}";
  version = "2017-02-08";
  src = fetchFromGitHub {
    owner = "Floobits";
    repo = "floobits-neovim";
    rev = "9755412fcd68cfc76a36aa000682a84d96013650";
    sha256 = "1mn6kikygk86xblxg8kklkrrxagil4az76z0mzid847g4jw4hfd1";
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

"haskell-vim" = {stdenv, fetchFromGitHub}: stdenv.mkDerivation (pluginAttrs rec {
  name = "haskell-vim-${version}";
  version = "2017-04-03";
  src = fetchFromGitHub {
    owner = "neovimhaskell";
    repo = "haskell-vim";
    rev = "9811f3803317c4f39c868e71b3202b5559735aef";
    sha256 = "02f87lfpr5lslh57cqimg91llflra8934jzy0g32l5zcm7fdljdk";
  };
  patches = [
    plug-patches/no-space-indent.patch
    plug-patches/cabal-module-word.patch
  ];
});

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

"lightline.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "lightline.vim-${version}";
  version = "2017-04-16";
  src = fetchFromGitHub {
    owner = "itchyny";
    repo = "lightline.vim";
    rev = "15509c6fa6b15c36d6bbb0068d4cfa8a2e24c003";
    sha256 = "0wwac1irjx29sgiyfnk2xyc1nmrjb92h4p829389iz44p0hgvwrp";
  };
};

"neco-ghc" = {stdenv, fetchFromGitHub}: stdenv.mkDerivation (pluginAttrs rec {
  name = "neco-ghc-${version}";
  version = "2016-07-01";
  src = fetchFromGitHub {
    owner = "eagletmt";
    repo = "neco-ghc";
    rev = "7f02a9c25fb272a87d2be092826e2cd3094c620d";
    sha256 = "1fcfk45qb96h6y4zb3p0104iyqc85q1synn9ah56zp6hnkkyffbw";
  };
  patches = [
    plug-patches/streamline-neco-ghc.patch
  ];
});

"neco-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "neco-vim-${version}";
  version = "2017-04-06";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neco-vim";
    rev = "c58ce68df75af8928ce9d4c19dab3b3ff7de3fb2";
    sha256 = "1w56s75891y8p2ng1mgmir58hlckk7ad6mz87xms2kkkx0xbqzl9";
  };
};

"neomake" = {stdenv, fetchFromGitHub}: stdenv.mkDerivation (pluginAttrs rec {
  name = "neomake-${version}";
  version = "2017-04-18";
  src = fetchFromGitHub {
    owner = "neomake";
    repo = "neomake";
    rev = "4233c65a1d4502188d8ed23e662be6629e9bcdc8";
    sha256 = "1kfyi68f01x7rp1xg691kqggg3xbp4m3n27vb5dslf78xgq9ijba";
  };
  patches = [
    plug-patches/always-quickfix.patch
    plug-patches/neomake-hdevtools.patch
  ];
});

"neosnippet-snippets" = {fetchFromGitHub}: vimPlugin rec {
  name = "neosnippet-snippets-${version}";
  version = "2017-03-29";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet-snippets";
    rev = "2a9487bacb924d8e870612b6b0a2afb34deea0ae";
    sha256 = "0917zlh7fin2172jmlbzkszb1dqafx6l0sgxf1nm1b0k083c9bjz";
  };
};

"neosnippet.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "neosnippet.vim-${version}";
  version = "2017-04-18";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet.vim";
    rev = "1a6653b69dad08be197153c3a2790e4d79ba3bd3";
    sha256 = "1plsnkjfkdb5nrkasy3dsqq115cb9gmw67pf9mdwhc5mvvgd12sg";
  };
};

"neovim-fuzzy" = {fetchFromGitHub}: vimPlugin rec {
  name = "neovim-fuzzy-${version}";
  version = "2017-04-10";
  src = fetchFromGitHub {
    owner = "cloudhead";
    repo = "neovim-fuzzy";
    rev = "9bb6d8f82080950fabc7224c8637a2d3d6dd4db4";
    sha256 = "1079d0mb4kf9xl787x28si80kqiras0vc8byyjb59100yvdjphs6";
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

"vim-commentary" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-commentary-${version}";
  version = "2017-03-12";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-commentary";
    rev = "be79030b3e8c0ee3c5f45b4333919e4830531e80";
    sha256 = "1msbmbz96wa88ymjvcrbr07mxdrsjy1w2hl7z4pihf318ryq98cm";
  };
};

"vim-diminactive" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-diminactive-${version}";
  version = "2016-06-21";
  src = fetchFromGitHub {
    owner = "blueyed";
    repo = "vim-diminactive";
    rev = "fce5469baa086ae4b72622dc1f81eda26df36e95";
    sha256 = "04jp8i6gbqsz36663zmpb3fanhmkxjx55jsvzbhf0fgnghagp25g";
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
  version = "2017-04-11";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-fugitive";
    rev = "b2665cc65002c3ebf3aa771bb1b65ea8ef6b57d6";
    sha256 = "113j1l6hhf37kmja99bqx8jif2b5f04q063arqb0a8fs1sg42mxh";
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

"vim-hdevtools" = {stdenv, fetchFromGitHub}: stdenv.mkDerivation (pluginAttrs rec {
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
});

"vim-hoogle" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-hoogle-${version}";
  version = "2017-03-01";
  src = fetchFromGitHub {
    owner = "Twinside";
    repo = "vim-hoogle";
    rev = "cfb0c864dbacf6f916ba05c4a688e21154aa971b";
    sha256 = "0gddyh47gwy684kjs9yxfnc0lg8jq9w5pdyv3yrvypyiqi51vw1b";
  };
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
  version = "2016-11-02";
  src = fetchFromGitHub {
    owner = "LnL7";
    repo = "vim-nix";
    rev = "b06cccd8ff61149b13d3fc8b7e0d06caa55c9888";
    sha256 = "0d1wxxijyyl449f81asl9d31kg0wvs3m0fypin172ahgpf3lyar4";
  };
};

"vim-obsession" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-obsession-${version}";
  version = "2015-06-17";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-obsession";
    rev = "ad1ef9a0db9a03463b005b488fd27cb735317394";
    sha256 = "1nkxdxlq2b7lg7kr4bszi97p2k08zyz2m9z425chk5xkb2y2dg20";
  };
};

"vim-repeat" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-repeat-${version}";
  version = "2015-05-09";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-repeat";
    rev = "7a6675f092842c8f81e71d5345bd7cdbf3759415";
    sha256 = "0p8g5y3vyl1765lj1r8jpc06l465f9bagivq6k8ndajbg049brl7";
  };
};

"vim-rhubarb" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-rhubarb-${version}";
  version = "2017-04-10";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-rhubarb";
    rev = "9032c184f8caffac782279a00c70031a53305804";
    sha256 = "1xqga83jl2qknsajq9z6vwlzr0pwrrx0z9sy69pyw5y9rcvpzd1z";
  };
};

"vim-startify" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-startify-${version}";
  version = "2017-04-07";
  src = fetchFromGitHub {
    owner = "mhinz";
    repo = "vim-startify";
    rev = "f80b0cbe62c1b70062882093db074c707b79237b";
    sha256 = "0zjnycr9xpy8sqz7j21lk6xfqlbjh3p9zlr9qqlkw56nh9bilhak";
  };
};

"vim-stylish-haskell" = {stdenv, fetchFromGitHub}: stdenv.mkDerivation (pluginAttrs rec {
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
  ];
});

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
  version = "2017-04-03";
  src = fetchFromGitHub {
    owner = "dhruvasagar";
    repo = "vim-table-mode";
    rev = "35b41e082212776006fb7c18b406545ed8395ad8";
    sha256 = "028n4wi6i20rsr7lvwvdkv48arypbqy4db0zaz35chfpm0wfn5aw";
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

"vim-textobj-haskell" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-textobj-haskell-${version}";
  version = "2014-10-27";
  src = fetchFromGitHub {
    owner = "gibiansky";
    repo = "vim-textobj-haskell";
    rev = "ca656e98ea31e201f5bc543909398a6c8bb5d537";
    sha256 = "096pjjl3ngw0hsh59j2x6pdrpqvp657rcxfyl9kw13ndqyd867xs";
  };
};

"vim-textobj-user" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-textobj-user-${version}";
  version = "2015-05-03";
  src = fetchFromGitHub {
    owner = "kana";
    repo = "vim-textobj-user";
    rev = "a3054162c09bcf732624f43ddacbd85dad09713b";
    sha256 = "13ip7c611ghn1z4q711kd19mr6a71pxiyqj72xyvw40hslbw3n50";
  };
};

"vim-tmux-focus-events" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-tmux-focus-events-${version}";
  version = "2015-10-25";
  src = fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "vim-tmux-focus-events";
    rev = "eccc2f54cd6f006840c20cc017ef79c4eb431cd9";
    sha256 = "0yhv5alb09c757r0a8x13hwh28y8z0djmxspqhap6qml07i3xhyg";
  };
};

"vim-tmux-navigator" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-tmux-navigator-${version}";
  version = "2017-02-26";
  src = fetchFromGitHub {
    owner = "christoomey";
    repo = "vim-tmux-navigator";
    rev = "2fc1ed42ab580ab47c506ab0bef09f1dbb9ff04d";
    sha256 = "1mw0x3kcxvhfypzd7yj6bcknp6c5bh4zb4r9b16n1r7gplvwv8jn";
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
  version = "2017-03-28";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-unimpaired";
    rev = "e939771979393c502e2331fc7d44a963efd7bb46";
    sha256 = "0i782gq926g9a97bv14d1gxl96mxwpwmw5dgdn1h9k0xyi7fxk54";
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
  version = "2017-02-24";
  src = fetchFromGitHub {
    owner = "stephpy";
    repo = "vim-yaml";
    rev = "a1a8fc8aea112ef4956d78626ade6c0cb832f9d2";
    sha256 = "0nzh6is6wmhzb4aml4hawf75y3q4c1l1v6fi5wrj6c7z0kans9wi";
  };
};

"vimproc.vim" = {stdenv, fetchFromGitHub, which}: stdenv.mkDerivation rec {
  name = "vimproc.vim-${version}";
  version = "2016-08-06";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "vimproc.vim";
    rev = "25cb83f24edec4aec1e9f1329302235e7a7a7fe0";
    sha256 = "19nl21623cv05j6ljyn35qm38pw3680nch2by1gapqmxazp99i20";
  };
  buildInputs = [ which ];
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
};

"webapi-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "webapi-vim-${version}";
  version = "2017-03-13";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "webapi-vim";
    rev = "54b0c168dfbd3fd4a7d876a3cead1bdaf7810b0a";
    sha256 = "1mjj87f1sb9kmpkclv9qpbmsf6j6nr536636867k1bis39rahkdg";
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

}
