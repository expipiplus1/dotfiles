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
  version = "2017-06-03";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "deoplete.nvim";
    rev = "2eb3fa505a649f2a81003252c7a5e06426e051a6";
    sha256 = "0llhd03c7aaj83wsclcfxv9m1vpxzx5d4xwxj737byhxhkkdrqnw";
  };
};

"deoplete-clang2" = {lessWrappedClang}: vimPlugin rec {
  name = "deoplete-clang2-${version}";
  version = "2017-04-03";
  src = fetchFromGitHub {
    owner = "tweekmonster";
    repo = "deoplete-clang2";
    rev = "787dd4dc7eeb5d1bc2fd3cefcf7bd07e48f4a962";
    sha256 = "07a153bgkk9q8jpxy2fbqsfr0bzn8mynq9hn22dfw1rrfvas51ym";
  };
  patchPhase = ''
    substituteInPlace rplugin/python3/deoplete/sources/deoplete_clang2.py \
      --replace "'deoplete#sources#clang#executable', 'clang')"  \
                "'deoplete#sources#clang#executable', '${lessWrappedClang}/bin/clang')" 
  '';
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

"haskell-vim" = {}: vimPlugin rec {
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
  version = "2017-05-30";
  src = fetchFromGitHub {
    owner = "itchyny";
    repo = "lightline.vim";
    rev = "ff74d6561487d220ed9d878172d8b55a79a4c17e";
    sha256 = "0j8pn42vfc1ka6hjnfsanl98vlk2839am5d4ynz9p1j1hichiqzv";
  };
};

"neco-ghc" = {}: vimPlugin rec {
  name = "neco-ghc-${version}";
  version = "2017-04-30";
  src = fetchFromGitHub {
    owner = "eagletmt";
    repo = "neco-ghc";
    rev = "aeb84b9ef05d1c5b0c835365ddcd424930fb0cd2";
    sha256 = "1yhdrjqw5chq7jgk397swh4axpv6m4aqracyqmx4bb65pzqbwdxl";
  };
  patches = [
    plug-patches/streamline-neco-ghc.patch
  ];
};

"neco-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "neco-vim-${version}";
  version = "2017-04-25";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neco-vim";
    rev = "2329ad0a20af61ac104a29d3653e5af24add7077";
    sha256 = "1mf7xdlarwj2kfx3pbngrvfrzmbjp6k5f6bxl4n1wz9p7wdajap8";
  };
};

"neomake" = {lessWrappedClang, clang-tools}: vimPlugin rec {
  name = "neomake-${version}";
  version = "2017-06-02";
  src = fetchFromGitHub {
    owner = "neomake";
    repo = "neomake";
    rev = "991a6faed3c388a3f41bb6ce4307915a7f7b902a";
    sha256 = "0f2196cdhwmj2pqp1xwqqkwkzk846gd4dirqv1f6h5wwb7glygfn";
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
  version = "2017-04-23";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet.vim";
    rev = "9996520d6bf1aaee21f66b5eb561c9f0b306216c";
    sha256 = "0j7z05br2cjdssdks3mac51xmr7js192gy30811nzjizwm2hhcwk";
  };
};

"neovim-fuzzy" = {fetchFromGitHub}: vimPlugin rec {
  name = "neovim-fuzzy-${version}";
  version = "2017-05-28";
  src = fetchFromGitHub {
    owner = "cloudhead";
    repo = "neovim-fuzzy";
    rev = "e6c1086c1882015f8475377e30a9c02eb018552a";
    sha256 = "0zhbhc1pxi47w79b1wdqjs050xvmzwgysimh1df6vvnmiwajm4qa";
  };
};

"open-browser.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "open-browser-github.vim-${version}";
  version = "2017-03-10";
  src = fetchFromGitHub {
    owner = "tyru";
    repo = "open-browser.vim";
    rev = "b0dccb3be0f708d189420463ebff1838dea01a58";
    sha256 = "06yzh2pkmzz19ivlk1wfc16bwc7vi3k3hiwnfbry4n7vmbpjh3zl";
  };
};


"open-browser-github.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "open-browser-github.vim-${version}";
  version = "2017-03-10";
  src = fetchFromGitHub {
    owner = "tyru";
    repo = "open-browser-github.vim";
    rev = "da68ff743192d1196df2150043bd4ece6bee8f7a";
    sha256 = "070nx7iq5zzglrwa3dl52i5zhp6ljq6ib13s77c0cn7wnz9x18rk";
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
  version = "2017-03-10";
  src = fetchFromGitHub {
    owner = "rhysd";
    repo = "vim-clang-format";
    rev = "a2aa8afee7208ad138415b6f2e730ae74dc20997";
    sha256 = "0fwilad24yhl608ym8z7kgdf0ppa9xljp4cj4yhiig2sadslyyg1";
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
  version = "2017-05-12";
  src = fetchFromGitHub {
    owner = "blueyed";
    repo = "vim-diminactive";
    rev = "c34d88ef37c34cec57b95e5687a18a1068310e61";
    sha256 = "1jy2glcab9xv6jq24qf8k6f6lpdcwl1q5fd5fhhzv57m1260qvxs";
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
  version = "2017-05-30";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-fugitive";
    rev = "7195586b7952a49c3de90dc7dc25c262116eaa83";
    sha256 = "026r3x4hf92c0sybfxs5yj59n6pmwl1ympy6ljgcgk4pwlj5vix1";
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
  version = "2017-03-01";
  src = fetchFromGitHub {
    owner = "Twinside";
    repo = "vim-hoogle";
    rev = "cfb0c864dbacf6f916ba05c4a688e21154aa971b";
    sha256 = "0gddyh47gwy684kjs9yxfnc0lg8jq9w5pdyv3yrvypyiqi51vw1b";
  };
};

"vim-markdown" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-markdown-${version}";
  version = "2018-02-07";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-markdown";
    rev = "8a712f46753918e012a57b9badac8c0b628681d9";
    sha256 = "06ri44b40z2rd282bviilwr320kb5mlnd63xwp6f6xp4gn3fhl4w";
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
  version = "2017-04-30";
  src = fetchFromGitHub {
    owner = "LnL7";
    repo = "vim-nix";
    rev = "867488a04c2ddc47f0f235f37599a06472fea299";
    sha256 = "1mwc06z9q45cigyxd0r9qnfs4ph6lbcwx50rf5lmpavakcn3vqir";
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
  version = "2017-04-21";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-repeat";
    rev = "070ee903245999b2b79f7386631ffd29ce9b8e9f";
    sha256 = "1grsaaar2ng1049gc3r8wbbp5imp31z1lcg399vhh3k36y34q213";
  };
};

"vim-rhubarb" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-rhubarb-${version}";
  version = "2017-05-23";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-rhubarb";
    rev = "feac2474db8ac06c1c520dfac768e9318e00be13";
    sha256 = "1mp5zarpc44w53z3pb77hsam488sm726zrc68k193rkx8dq7wysw";
  };
};

"vim-startify" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-startify-${version}";
  version = "2017-05-30";
  src = fetchFromGitHub {
    owner = "mhinz";
    repo = "vim-startify";
    rev = "ae8cfbb9dbbcb16c2da57fc3219834a89428b644";
    sha256 = "1qzfibkjnpdn12n02bc11099yp3wycnnw43w9mp1fhlzq81ziviq";
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
  version = "2017-04-20";
  src = fetchFromGitHub {
    owner = "dhruvasagar";
    repo = "vim-table-mode";
    rev = "4e41af8e5f0bf53326d1b83c2feb1eff89fe90d4";
    sha256 = "0l83j3963lzkmn54vcagkwm2rhk96cl9v42l5r7zcgjign28cfzw";
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
  version = "2017-06-01";
  src = fetchFromGitHub {
    owner = "christoomey";
    repo = "vim-tmux-navigator";
    rev = "b93e176b7150942d9f0556347d1c8f6d0b690124";
    sha256 = "1xjvx4svv1kdqmv114ghx7cfrb5kmbljlwac8bsw36rq3kyknwrn";
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
  version = "2017-05-22";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-unimpaired";
    rev = "7bbbca73233b1492a8c3d16f91f34340eccc9b30";
    sha256 = "064iknlgffj7mn0vibmw1j5rwsv7fbyavaf7h4gib4h79x2sgm5w";
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
  version = "2017-05-02";
  src = fetchFromGitHub {
    owner = "stephpy";
    repo = "vim-yaml";
    rev = "c21962fa4fc088f17a8e37854430ec7fa16dec13";
    sha256 = "0c08pd8ia7k1h05lrki5g1j3m7vzinxy000s926ak7g467a0dyki";
  };
};

"vimproc.vim" = {stdenv, fetchFromGitHub, which}: mkDerivation rec {
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
  version = "2017-04-26";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "webapi-vim";
    rev = "e76f2da9a8f292a999a95ae688534f76c2dca9bd";
    sha256 = "02970g7blj478vid88gayba39rdcm9236nigkrijapyf5rd24zhh";
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
