{ pkgs, neovim-unconfigured }:


let
  inherit (pkgs.stdenv) mkDerivation;
  inherit (pkgs) fetchFromGitHub;

  vimPlugin = { name, version, src, postPatch ? "", patches ? [], patchPhase ? "" }: mkDerivation {
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
  };

  postInstall = ''
    # From vimHelpTags in nixpkgs
    if [ -d "$out/doc" ]; then
      ${neovim-unconfigured}/bin/nvim -N -u NONE -i NONE -n -E -s -c "helptags $out/doc" +quit! || (echo "docs to build failed" && false)
    fi
  '';

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
  version = "2018-01-04";
  src = fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-vim";
    rev = "97f2feb554471760f72cb6e4f872fde0f825b4b3";
    sha256 = "1klrd5gm6l0bs7ngcngdfzx0yq1w8cpmgxc7hi48xssz58qn5dw7";
  };
};

"comfortable-motion.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "comfortable-motion.vim-${version}";
  version = "2018-02-20";
  src = fetchFromGitHub {
    owner = "yuttie";
    repo = "comfortable-motion.vim";
    rev = "e20aeafb07c6184727b29f7674530150f7ab2036";
    sha256 = "13chwy7laxh30464xmdzjhzfcmlcfzy11i8g4a4r11m1cigcjljb";
  };
};

"deoplete.nvim" = {fetchFromGitHub}: vimPlugin rec {
  name = "deoplete.nvim-${version}";
  version = "2018-03-12";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "deoplete.nvim";
    rev = "c3c9406bfb4207c057d6a366c88466256a6ea2bd";
    sha256 = "13ks62da4lrcwcy3ip95nzyfvadfcjrww7c9n5322nibqqgcbda5";
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
  version = "2018-01-25";
  src = fetchFromGitHub {
    owner = "neovimhaskell";
    repo = "haskell-vim";
    rev = "430b529224c5f9ae53b148f814b7b1fc82b8b525";
    sha256 = "15z259b9b3wbklc8rndsq2rlhgccvxhfgd76yy80jqjmfmzib8kg";
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

"lightline.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "lightline.vim-${version}";
  version = "2018-01-31";
  src = fetchFromGitHub {
    owner = "itchyny";
    repo = "lightline.vim";
    rev = "78c43c144643e49c529a93b9eaa4eda12614f923";
    sha256 = "1g1s8bi6pzjc9kbqd1mn1d2ym6c90xf22dv2wfli0nyp6dsja2v2";
  };
};

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

"neomake" = {lessWrappedClang, clang-tools}: vimPlugin rec {
  name = "neomake-${version}";
  version = "2018-03-17";
  src = fetchFromGitHub {
    owner = "neomake";
    repo = "neomake";
    rev = "a737744f53d28d5b279ba96dd6b87ead4a7255e3";
    sha256 = "1xjws0l8byrdaa04yw013pxqdp95qmn7iqqmxnyhjx1q67wibhv7";
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

"neosnippet-snippets" = {fetchFromGitHub}: vimPlugin rec {
  name = "neosnippet-snippets-${version}";
  version = "2018-03-12";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet-snippets";
    rev = "4aaa1713c88a74e340a97afa80d0b935f60bfecd";
    sha256 = "10i2b9b8la3ia2f0nkg2bfjz54h0b1slqn1jrb7a8iwg5jmsn7yh";
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
  version = "2017-10-09";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-commentary";
    rev = "89f43af18692d22ed999c3097e449f12fdd8b299";
    sha256 = "0nqm4s00c607r58fz29n67r2z5p5r9qayl5y1chy8bcrl59m17a2";
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
  version = "2018-03-14";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-fugitive";
    rev = "3e0bd86b99c50691f830d9e25a4bbe2a88078f8f";
    sha256 = "1prfb0m61r499i35qn1ql2pag5w64mhpkby4wbbvlpm50xwq8w9b";
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
  version = "2018-02-25";
  src = fetchFromGitHub {
    owner = "LnL7";
    repo = "vim-nix";
    rev = "36c5feb514930e8fb8e2f4567d6b0d9e806fc2eb";
    sha256 = "1v0vm0h5j6zzwhm5gw3xcmckswma3a5kxyli34i8hy14yli0ff3d";
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
  version = "2018-03-18";
  src = fetchFromGitHub {
    owner = "mhinz";
    repo = "vim-startify";
    rev = "50d4c51607c5301b70804a864e15b689e25876ff";
    sha256 = "1rlzw6kp7d6drgmz27l33jh830cm0ir65w7drgs400dpzzlc233w";
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
  version = "2018-03-17";
  src = fetchFromGitHub {
    owner = "dhruvasagar";
    repo = "vim-table-mode";
    rev = "d0a640518957417ce689411d807dff3bf9eca194";
    sha256 = "1b6mka45lhb7n06pjxg697ha63gg4vw6zgj0v037w1izj619xa33";
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

}
