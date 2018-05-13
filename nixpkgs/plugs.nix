{ pkgs, neovim-unconfigured, extraAttrs ? {} }:


let
  useHIE = true;

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
  version = "2018-05-04";
  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf";
    rev = "b8296a91b94d7af73a2290564b15282d7810e9e4";
    sha256 = "05vqfc27ss3283v772vc7p9flv022v8xjpy401kvq95vyi7d0fxp";
  };
};

"fzf.vim" = {}: vimPlugin rec {
  name = "fzf.vim-${version}";
  version = "2018-04-28";
  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf.vim";
    rev = "88595ebbaa33485cd1a4474701bd0e5809643520";
    sha256 = "1cbv23vmiss4id6slngm381zwqm20zl0bjx3dg5qhh89xhrvxjz6";
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
  version = "2018-04-27";
  src = fetchFromGitHub {
    owner = "neovimhaskell";
    repo = "haskell-vim";
    rev = "a5302e09292a1ca00aa48927332ea77f7de5409d";
    sha256 = "1s2y82c70aihn1nkwqn0f8vkd5kv8a70p6vp6s6xq2lq9zic6m7h";
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
  version = "2018-04-28";
  src = fetchFromGitHub {
    owner = "itchyny";
    repo = "lightline.vim";
    rev = "41fb97e85b0386b976b39051de4f7eaa42ba6b2b";
    sha256 = "0b4q7acb1rpq295hhvm6x9d4lhanrp75zn3yr9l7siliw40fcrb1";
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
  version = "2018-05-01";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet.vim";
    rev = "fa7cc15aee58157d54e0965e70c00305764058f4";
    sha256 = "150pz2abcwjfh8v4i42mgsj9k2n3qniqnkzir39c0zx6rg36mwy3";
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
  version = "2018-04-26";
  src = fetchFromGitHub {
    owner = "tyru";
    repo = "open-browser.vim";
    rev = "de4eeb085051e9b56dd5574eba7c7e72feb21246";
    sha256 = "1fgp4wwizpknfwscxraqqaxrhvwp9l1mnjwj3llk2x0n9qcqf1db";
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
  version = "2018-05-11";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-fugitive";
    rev = "b14434bae0357dd47b33f940c3a02510c44fbbe2";
    sha256 = "1jljg1wmr5sl2750ghgxs4yhwmbmxik87h3r5b9qrh7gg3ybi6hj";
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
  version = "2018-04-24";
  src = fetchFromGitHub {
    owner = "LnL7";
    repo = "vim-nix";
    rev = "dae3d30a145f1d0e50658dafd88f95cd4b5e323d";
    sha256 = "1x3gaiz2wbqykzhk0zj0krjp81m5rxhk80pcg96f4gyqp7hxrx78";
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
  version = "2018-05-05";
  src = fetchFromGitHub {
    owner = "mhinz";
    repo = "vim-startify";
    rev = "fbd690fc85a06669a518b2f201f44a26e66fd84b";
    sha256 = "0wnc4ka2bhy7lhvnzghhkhsms8hvyhjagmpk4qw410f1i8grpq02";
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
  version = "2018-05-08";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-unimpaired";
    rev = "02d954e3252d1e4c0bb74178d7a65ded67c5c17e";
    sha256 = "0zhhwjr17pwhz4z42jybmzvwwhfsi1asq477g2llba148fd7f2hd";
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
  version = "2018-05-10";
  src = fetchFromGitHub {
    owner = "neomake";
    repo = "neomake";
    rev = "150fbb69d3202afb29f6db7a9a7e93da26d776a6";
    sha256 = "01vpyadz4n2rxm3rqsipq3wbqblvpx54nx49kxfnvk9skd24d024";
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
    # version = "2018-01-07";
    # name = "LanguageClient-neovim-${version}";
    # src = fetchFromGitHub {
    #   owner = "autozimu";
    #   repo = "LanguageClient-neovim";
    #   rev = "948677f90d5832baab5f3359b85c2c69d0d3d359";
    #   sha256 = "06ihrxs0ddvsapminpii90knqqzv7na09wnpbmdaz8sichrr9xj4";
    # };
    # pkgs_ = pkgs;
    # bin =
    #   let
    #     pkgs = (
    #       let
    #         nixpkgs = import pkgs_.path;
    #         rustOverlay = /home/j/src/nixpkgs-mozilla;
    #       in (nixpkgs {
    #         overlays = [
    #           (import (builtins.toPath "${rustOverlay}/rust-overlay.nix"))
    #           (self: super: {
    #             rust = {
    #               rustc = super.rustChannels.stable.rust;
    #               cargo = super.rustChannels.stable.cargo;
    #             };
    #             rustPlatform = super.recurseIntoAttrs (super.makeRustPlatform {
    #               rustc = super.rustChannels.stable.rust;
    #               cargo = super.rustChannels.stable.cargo;
    #             });
    #           })
    #         ];
    #       }));
    #   in pkgs.rustPlatform.buildRustPackage {
    #        inherit name src;
    #        cargoSha256 = "1vafyi650qdaq1f7fc8d4nzrv1i6iz28fs5z66hsnz4xkwb3qq9w";
    # };
  # in vimPlugin rec {
    # inherit name version src;
    # postPostInstall = ''
    #   ln -s "${bin}/bin/languageclient" "$out/bin/languageclient"
    # '';
  # };
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
};

in plugs
