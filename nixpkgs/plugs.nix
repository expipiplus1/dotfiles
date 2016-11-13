let 
  vimPlugin = { name, version, src }: src;
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
  version = "2016-08-06";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "deoplete.nvim";
    rev = "e7761c3ad800882ea72c6b240107d6eb276f3c1f";
    sha256 = "18fg90kfy5x2xz7gz033v5m9sni55lf41sfiajafxh571cd44nf4";
  };
};

"gist-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "gist-vim-${version}";
  version = "2015-10-25";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "gist-vim";
    rev = "88c331e2e07765090112a396e5e119b39b5aa754";
    sha256 = "0z7qnkgv8ryyiwikz6v6vpqypr2gh2hih27cil02rs4ci4041w74";
  };
};

"haskell-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "haskell-vim-${version}";
  version = "2016-11-12";
  src = fetchFromGitHub {
    owner = "neovimhaskell";
    repo = "haskell-vim";
    rev = "e6f3093b14f6c603c0e66d8814b9d053843f7133";
    sha256 = "02k5c4xnlz6xs18inygnh4phayhyx8n0l5haslsy7rp5w7arvmsj";
  };
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
  version = "2016-06-12";
  src = fetchFromGitHub {
    owner = "itchyny";
    repo = "lightline.vim";
    rev = "430ce2cb063b39a0c7950cafd617e333acb6759a";
    sha256 = "0336c17vkfh60cvj86y35lqz1xcd80csrlb985k1hyd5s7cayp42";
  };
};

"neco-ghc" = {fetchFromGitHub}: vimPlugin rec {
  name = "neco-ghc-${version}";
  version = "2016-07-02";
  src = fetchFromGitHub {
    owner = "expipiplus1";
    repo = "neco-ghc";
    rev = "5326bc057d86750593fab1fcecefb5516cb6284e";
    sha256 = "1wkakiagq05djn4nnaqzq0jglnp0rjznqd0kq3lsvkgqmjys7vf1";
  };
};

"neco-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "neco-vim-${version}";
  version = "2016-03-31";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neco-vim";
    rev = "dd9418ebeb6cd6563e0996f1784366e0b6224647";
    sha256 = "1zy1g0d100vwv6iprhhm6vsg64r2vddp26h9z0qbbrrrk3qri11d";
  };
};

"neomake" = {fetchFromGitHub}: vimPlugin rec {
  name = "neomake-${version}";
  version = "2016-08-08";
  src = fetchFromGitHub {
    owner = "expipiplus1";
    repo = "neomake";
    rev = "d3facce1214a8374687f559ddf20cdf4da8c0e8a";
    sha256 = "0hyiwpfafzaars4a70pml1agaygjbyzvl9v4v6fqg0cdp1x6v1wc";
  };
};

"neosnippet-snippets" = {fetchFromGitHub}: vimPlugin rec {
  name = "neosnippet-snippets-${version}";
  version = "2016-07-14";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet-snippets";
    rev = "4d25b4352738ecf34e56701d0172d80daa3bd287";
    sha256 = "01lai1gvf30iagh9f7av69ywfzw43vy2igwil882rgnri84y4zjb";
  };
};

"neosnippet.vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "neosnippet.vim-${version}";
  version = "2016-07-10";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "neosnippet.vim";
    rev = "9492fbb7e9016243af3c1987b91f0bffcf4cc8e7";
    sha256 = "0p2d762z0s9ayrc4kcqr7s1hmcghd04z818szqdn6v6rsr9lyln8";
  };
};

"neovim-fuzzy" = {fetchFromGitHub}: vimPlugin rec {
  name = "neovim-fuzzy-${version}";
  version = "2016-10-26";
  src = fetchFromGitHub {
    owner = "cloudhead";
    repo = "neovim-fuzzy";
    rev = "aa6681f2b8b2f2de2c851d0ecff6b548f94e51d6";
    sha256 = "1fimpfc8x3dawgfj3k3mbj9sf9s2x3m66hz62b811d74wdix7az2";
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
  version = "2016-07-11";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-abolish";
    rev = "125908e01dd69294743c7e22d3028855158aa44c";
    sha256 = "08qgyhnqngmk79y3mrw5rr4crjy4wsi6f43l4rf83b8cbdkg5pc7";
  };
};

"vim-commentary" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-commentary-${version}";
  version = "2016-03-10";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-commentary";
    rev = "73e0d9a9d1f51b6cc9dc965f62669194ae851cb1";
    sha256 = "1z409hpdk22v2ccx2y3sgcjf4fmnq7pyjfnk72srpqydfivxsl13";
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
  version = "2016-07-06";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-fugitive";
    rev = "c00ebd75ac23f4080c0d0bf9453b16304a3fb316";
    sha256 = "0j8vy6n70m02k2iq4y4nbpc0jnzk1ag51qnnbxj7aad4hkn8hban";
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

"vim-hdevtools" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-hdevtools-${version}";
  version = "2016-07-08";
  src = fetchFromGitHub {
    owner = "parsonsmatt";
    repo = "vim-hdevtools";
    rev = "43ec8a167b3c69500f291a0e58a6779a3898de26";
    sha256 = "198qabn6r5hvjbj9dlb7avzywhh3d5zghgdpli2x119ky1cgkmvq";
  };
};

"vim-hoogle" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-hoogle-${version}";
  version = "2015-12-24";
  src = fetchFromGitHub {
    owner = "Twinside";
    repo = "vim-hoogle";
    rev = "a5db36f048ac16ab9774fc86f36cd4ae9a444932";
    sha256 = "1855n6dsimbc0brfbmmkx1gszhmgfghm1h1mpi95mq9qzbwkgjri";
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
  version = "2016-08-07";
  src = fetchFromGitHub {
    owner = "LnL7";
    repo = "vim-nix";
    rev = "a61495a762feacc00f24cab4392b09cc3250decf";
    sha256 = "0icq9nawm6s4qzb9q62y3fdq4ixbfwmmgk141fnfqzq6ya1azxac";
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
  version = "2016-06-17";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-rhubarb";
    rev = "0c12c7ed7caf32bb7d7fd749c5ac8981023dbb24";
    sha256 = "1wx1vwnmsaw3b4nk74fp5mljnza1ra25qglw5ipkpj4dh27vd5sn";
  };
};

"vim-sensible" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-sensible-${version}";
  version = "2016-03-18";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-sensible";
    rev = "9e91be7e0fb42949831fe3161ef583363648aa58";
    sha256 = "1g1l3v33g9229r4g4kcx8m1yrh397yf3fn6bxis57n3lg6lmb6wm";
  };
};

"vim-startify" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-startify-${version}";
  version = "2016-07-21";
  src = fetchFromGitHub {
    owner = "mhinz";
    repo = "vim-startify";
    rev = "3f7b8d7b5e8b9f7670f7bcfab3596cb72930ca5e";
    sha256 = "00shnn7wmi3y3354ppd4dgjkxzdnj6cc9wa5sp998y7jlxnc84i9";
  };
};

"vim-stylish-haskell" = {fetchFromGitHub}: vimPlugin rec {
  name = "vim-stylish-haskell-${version}";
  version = "2016-03-28";
  src = fetchFromGitHub {
    owner = "expipiplus1";
    repo = "vim-stylish-haskell";
    rev = "ad6c8ecceb90be8311b2bed7426c38981133f220";
    sha256 = "1rr1611lip3jl80wznvnrifjj4hkhwkk31vralr06mlar4h0izrx";
  };
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
  version = "2016-07-11";
  src = fetchFromGitHub {
    owner = "dhruvasagar";
    repo = "vim-table-mode";
    rev = "96236638a80fe73fa649824c9df25831a0042373";
    sha256 = "1c5xnm63hqw0jycwakdljs0f3mp26rjvd4llijrznpr9z2cvki8f";
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
  version = "2016-07-17";
  src = fetchFromGitHub {
    owner = "christoomey";
    repo = "vim-tmux-navigator";
    rev = "caf4c48141f9088632b457f488fb797af77c3ce1";
    sha256 = "0gj6klb296jqq8zi40q7ryparpbv85dx4ahx6gpfv85452zn7rml";
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
  version = "2015-12-28";
  src = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-unimpaired";
    rev = "11dc568dbfd7a56866a4354c737515769f08e9fe";
    sha256 = "1an941j5ckas8l3vkfhchdzjwcray16229rhv3a1d4pbxifwshi8";
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
  version = "2014-10-10";
  src = fetchFromGitHub {
    owner = "stephpy";
    repo = "vim-yaml";
    rev = "06755a296f2248c91f020ccb4e0b3f211365037e";
    sha256 = "1wkb09xw7nx7dyi1cphhr6113jl76scplwnglcv9678ji6i8hkx1";
  };
};

"vimproc.vim" = {stdenv, fetchFromGitHub}: stdenv.mkDerivation rec {
  name = "vimproc.vim-${version}";
  version = "2016-08-06";
  src = fetchFromGitHub {
    owner = "Shougo";
    repo = "vimproc.vim";
    rev = "25cb83f24edec4aec1e9f1329302235e7a7a7fe0";
    sha256 = "19nl21623cv05j6ljyn35qm38pw3680nch2by1gapqmxazp99i20";
  };
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
};

"webapi-vim" = {fetchFromGitHub}: vimPlugin rec {
  name = "webapi-vim-${version}";
  version = "2016-07-06";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "webapi-vim";
    rev = "e3fa93f29a3a0754204002775e140d8a9acfd7fd";
    sha256 = "0z6s3cnipcww4q33d4dcp0p8jw29izghcrj75fxy6dmy1yw2fbcr";
  };
};

}
