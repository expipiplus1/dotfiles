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

"fzf" = {}: vimPlugin rec {
  name = "fzf-${version}";
  version = "2019-04-18";
  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf";
    rev = "8eea45ef5003e115cbbefc3a7fd9a81fea406bf3";
    sha256 = "0zppxwndnjxvg230p5yc25hbivpyswgzn3yd82qjjchcn9lvxiyy";
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

"ncm2-path" = {fetchFromGitHub}: vimPlugin rec {
  name = "ncm2-${version}";
  version = "2019-02-20";
  src = fetchFromGitHub {
    owner = "ncm2";
    repo = "ncm2-path";
    rev = "84b1e6b5f28ced2245ff08e6694101f029fdfca8";
    sha256 = "0yqga8d423k2j6iknkyx1qs1shddpshi4sx78992sa15dax9d394";
  };
};

"ncm2-bufword" = {fetchFromGitHub}: vimPlugin rec {
  name = "ncm2-${version}";
  version = "2019-01-20";
  src = fetchFromGitHub {
    owner = "ncm2";
    repo = "ncm2-bufword";
    rev = "1d42750114e47a31286268880affcd66c6ae48d5";
    sha256 = "14q76n5c70wvi48wm1alyckba71rp5300i35091ga197nkgphyaz";
  };
};


"tmux-complete.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "tmux-complete.vim-${version}";
  version = "2019-04-17";
  src = fetchFromGitHub {
    owner = "wellle";
    repo = "tmux-complete.vim";
    rev = "44372f32e2b43afde8b1a3c2231e5d5b8d76953a";
    sha256 = "12xsawx9a8v7jqnfq1xxqxrm0qdcnp8d3yzfsk7xw76askyh41xi";
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

# Strips whitespace
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

# Adds the :EasyAlign command
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

# Git
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

# Github support for fugitive
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

# "vim-misc" = {fetchFromGitHub}: vimPlugin rec {
#   name = "vim-misc-${version}";
#   version = "2015-05-21";
#   src = fetchFromGitHub {
#     owner = "xolox";
#     repo = "vim-misc";
#     rev = "3e6b8fb6f03f13434543ce1f5d24f6a5d3f34f0b";
#     sha256 = "0rd9788dyfc58py50xbiaz5j7nphyvf3rpp3yal7yq2dhf0awwfi";
#   };
# };

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

# "vim-stylish-haskell" = {}: vimPlugin rec {
#   name = "vim-stylish-haskell-${version}";
#   version = "2018-08-30";
#   src = fetchFromGitHub {
#     owner = "nbouscal";
#     repo = "vim-stylish-haskell";
#     rev = "0df8a2dd397f232a9ee0e56bc57071ccf29e21bf";
#     sha256 = "05f2ms2c914ycxjjd7csga89mpsk3wzyhi56vikg3nd7a8z54gzw";
#   };
#   patches = [
#     plug-patches/stylish-haskell.patch
#     # plug-patches/stylish-haskell-pos.patch
#     # plug-patches/stylish-haskell-args.patch
#   ];
# };

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
  version = "2019-04-18";
  src = fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "vim-tmux-focus-events";
    rev = "80335d871394592775da7e7abc701012045951a6";
    sha256 = "09zdqx72w659xr43nai9lrf16bhnhkajncj0628yc6jkhpf3wd2s";
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

# Quickfix and Loclist
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

# "vimproc.vim" = {stdenv, fetchFromGitHub, which}: mkDerivation rec {
#   name = "vimproc.vim-${version}";
#   version = "2019-03-10";
#   src = fetchFromGitHub {
#     owner = "Shougo";
#     repo = "vimproc.vim";
#     rev = "eb5b2b1248ccc8b1b9e84d7658508e38b964d17d";
#     sha256 = "0h9na94cg396mldqdasdkv30z67zp5r36794dlhh9j5kblc00x0v";
#   };
#   buildInputs = [ which ];
#   installPhase = ''
#     runHook preInstall
#     mkdir -p $out
#     cp -r * $out/
#     runHook postInstall
#   '';
#   inherit postInstall;
#   patches = [
#     plug-patches/vimproc-dll-loc.patch
#   ];
# };

# "webapi-vim" = {fetchFromGitHub}: vimPlugin rec {
#   name = "webapi-vim-${version}";
#   version = "2018-03-14";
#   src = fetchFromGitHub {
#     owner = "mattn";
#     repo = "webapi-vim";
#     rev = "252250381a9509257bfb06b9f95441e41e3e23b5";
#     sha256 = "0g37d1i6rxsj6f31g9jy2bhr8ng3jwmnvqqcmw19vbql4v56zq6a";
#   };
# };
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
      rev = "dce2a8e11f1a246c25f30a7668f3ab3e9eb0043e";
      sha256 = "039p3ixhiiaqnx70p4qfhxhmgd2kviy2vc8nv0yswk9w38kmpkqw";
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
    patches = [
      ./plug-patches/lc-i.patch
    ];
  };

"nvim-yarp" = {}: vimPlugin rec {
  name = "nvim-yarp-${version}";
  version = "2018-12-23";
  src = fetchFromGitHub {
    owner = "roxma";
    repo = "nvim-yarp";
    rev = "1524cf7988d1e1ed7475ead3654987f64943a1f0";
    sha256 = "1iblb9hy4svbabhkid1qh7v085dkpq7dwg4aj38d8xvhj9b7mf6v";
  };
};

};

in plugs
