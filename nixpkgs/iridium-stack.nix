# Generated using stack2nix 0.1.3.0.
#
# Only works with sufficiently recent nixpkgs, e.g. "NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/21a8239452adae3a4717772f4e490575586b2755.tar.gz".

{ pkgs ? (import <nixpkgs> {})
, compiler ? pkgs.haskell.packages.ghc7103
, ghc ? pkgs.haskell.compiler.ghc7103
}:

with (import <nixpkgs/pkgs/development/haskell-modules/lib.nix> { inherit pkgs; });

let
  stackPackages = { callPackage, pkgs, stdenv }:
self: {
      Cabal = callPackage ({ array, base, binary, bytestring, containers, deepseq, directory, filepath, mkDerivation, pretty, process, stdenv, time, unix }:
      mkDerivation {
          pname = "Cabal";
          version = "1.22.8.0";
          sha256 = "2a42a2ddecb6450f87ed3a2b37af81dcc573dfde8f0db16f695c78674a80a34e";
          libraryHaskellDepends = [
            array
            base
            binary
            bytestring
            containers
            deepseq
            directory
            filepath
            pretty
            process
            time
            unix
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://www.haskell.org/cabal/";
          description = "A framework for packaging Haskell software";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      StateVar = callPackage ({ base, mkDerivation, stdenv, stm, transformers }:
      mkDerivation {
          pname = "StateVar";
          version = "1.1.0.4";
          sha256 = "7ad68decb5c9a76f83c95ece5fa13d1b053e4fb1079bd2d3538f6b05014dffb7";
          libraryHaskellDepends = [
            base
            stm
            transformers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell-opengl/StateVar";
          description = "State variables";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      aeson = callPackage ({ attoparsec, base, bytestring, containers, deepseq, dlist, fail, ghc-prim, hashable, mkDerivation, mtl, scientific, stdenv, syb, tagged, template-haskell, text, time, transformers, unordered-containers, vector }:
      mkDerivation {
          pname = "aeson";
          version = "0.11.3.0";
          sha256 = "f326fac57881c228d91f610a2c92f083a60e3830d9c7d35dfb0a16925c95ece9";
          libraryHaskellDepends = [
            attoparsec
            base
            bytestring
            containers
            deepseq
            dlist
            fail
            ghc-prim
            hashable
            mtl
            scientific
            syb
            tagged
            template-haskell
            text
            time
            transformers
            unordered-containers
            vector
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/bos/aeson";
          description = "Fast JSON parsing and encoding";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      ansi-terminal = callPackage ({ base, mkDerivation, stdenv, unix }:
      mkDerivation {
          pname = "ansi-terminal";
          version = "0.6.2.3";
          sha256 = "4dc02cb53e9ca7c8800bbdfc0337b961e5a945382cd09a6a40c6170126e0ee42";
          isLibrary = true;
          isExecutable = true;
          libraryHaskellDepends = [
            base
            unix
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/feuerbach/ansi-terminal";
          description = "Simple ANSI terminal support, with Windows compatibility";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      ansi-wl-pprint = callPackage ({ ansi-terminal, base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "ansi-wl-pprint";
          version = "0.6.7.3";
          sha256 = "3789ecaa89721eabef58ddc5711f7fd1ff67e262da1659f3b20d38a9e1f5b708";
          isLibrary = true;
          isExecutable = true;
          libraryHaskellDepends = [
            ansi-terminal
            base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/ansi-wl-pprint";
          description = "The Wadler/Leijen Pretty Printer for colored ANSI terminal output";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      array = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "array";
          version = "0.5.1.0";
          sha256 = "b84bc8a6cd4526888a165e111ed23ba7af6c743608774d41604636a8990c1fa2";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "Mutable and immutable arrays";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      asn1-encoding = callPackage ({ asn1-types, base, bytestring, hourglass, mkDerivation, stdenv }:
      mkDerivation {
          pname = "asn1-encoding";
          version = "0.9.4";
          sha256 = "a78058f7db08fbd72f2b40c72af324a4d31ea95d70b4bfa372107b980394dde8";
          libraryHaskellDepends = [
            asn1-types
            base
            bytestring
            hourglass
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-asn1";
          description = "ASN1 data reader and writer in RAW, BER and DER forms";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      asn1-parse = callPackage ({ asn1-encoding, asn1-types, base, bytestring, mkDerivation, stdenv }:
      mkDerivation {
          pname = "asn1-parse";
          version = "0.9.4";
          sha256 = "c6a328f570c69db73f8d2416f9251e8a03753f90d5d19e76cbe69509a3ceb708";
          libraryHaskellDepends = [
            asn1-encoding
            asn1-types
            base
            bytestring
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/vincenthz/hs-asn1";
          description = "Simple monadic parser for ASN1 stream types";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      asn1-types = callPackage ({ base, bytestring, hourglass, memory, mkDerivation, stdenv }:
      mkDerivation {
          pname = "asn1-types";
          version = "0.3.2";
          sha256 = "0c571fff4a10559c6a630d4851ba3cdf1d558185ce3dcfca1136f9883d647217";
          libraryHaskellDepends = [
            base
            bytestring
            hourglass
            memory
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-asn1-types";
          description = "ASN.1 types";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      async = callPackage ({ base, mkDerivation, stdenv, stm }:
      mkDerivation {
          pname = "async";
          version = "2.1.1";
          sha256 = "24134b36921f9874abb73be90886b4c23a67a9b4990f2d8e32d08dbfa5f74f90";
          libraryHaskellDepends = [
            base
            stm
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/simonmar/async";
          description = "Run IO operations asynchronously and wait for their results";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      attoparsec = callPackage ({ array, base, bytestring, containers, deepseq, mkDerivation, scientific, stdenv, text, transformers }:
      mkDerivation {
          pname = "attoparsec";
          version = "0.13.1.0";
          sha256 = "52dc74d4955e457ce4f76f5c9d6dba05c1d07e2cd2a542d6251c6dbc66ce3f64";
          libraryHaskellDepends = [
            array
            base
            bytestring
            containers
            deepseq
            scientific
            text
            transformers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/bos/attoparsec";
          description = "Fast combinator parsing for bytestrings and text";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      base = callPackage ({ ghc-prim, mkDerivation, rts, stdenv }:
      mkDerivation {
          pname = "base";
          version = "4.8.2.0";
          sha256 = "f2bc9eb2773f74c231a25f32dc3b47b704cccc6b9064b6e1140dded364fafe8c";
          libraryHaskellDepends = [
            ghc-prim
            rts
          ];
          doHaddock = false;
          doCheck = false;
          description = "Basic libraries";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      base-orphans = callPackage ({ base, ghc-prim, mkDerivation, stdenv }:
      mkDerivation {
          pname = "base-orphans";
          version = "0.5.4";
          sha256 = "04075283606b3633f4b0c72f849a6df1b0519421ad099d07d3e72de589056263";
          libraryHaskellDepends = [
            base
            ghc-prim
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell-compat/base-orphans#readme";
          description = "Backwards-compatible orphan instances for base";
          license = stdenv.lib.licenses.mit;
        }) {};
      base64-bytestring = callPackage ({ base, bytestring, mkDerivation, stdenv }:
      mkDerivation {
          pname = "base64-bytestring";
          version = "1.0.0.1";
          sha256 = "ab25abf4b00a2f52b270bc3ed43f1d59f16c8eec9d7dffb14df1e9265b233b50";
          libraryHaskellDepends = [
            base
            bytestring
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/bos/base64-bytestring";
          description = "Fast base64 encoding and decoding for ByteStrings";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      bifunctors = callPackage ({ base, comonad, containers, mkDerivation, semigroups, stdenv, tagged, template-haskell, transformers }:
      mkDerivation {
          pname = "bifunctors";
          version = "5.2";
          sha256 = "46e173dac5863a7b8404b44ab1ead2de94e743d24a2de571ff086cfb8748de14";
          revision = "2";
          editedCabalFile = "091fysjy5gs3lixaaqngbh5bckshiafavb8z2i7yx5fqbji3d5bw";
          libraryHaskellDepends = [
            base
            comonad
            containers
            semigroups
            tagged
            template-haskell
            transformers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/bifunctors/";
          description = "Bifunctors";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      binary = callPackage ({ array, base, bytestring, containers, mkDerivation, stdenv }:
      mkDerivation {
          pname = "binary";
          version = "0.7.5.0";
          sha256 = "4709c5aa7cc99cb4a465a68de1648968208d0c60c368e2fece476d977530ef19";
          libraryHaskellDepends = [
            array
            base
            bytestring
            containers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/kolmodin/binary";
          description = "Binary serialisation for Haskell values using lazy ByteStrings";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      blaze-builder = callPackage ({ base, bytestring, deepseq, mkDerivation, stdenv, text }:
      mkDerivation {
          pname = "blaze-builder";
          version = "0.4.0.2";
          sha256 = "9ad3e4661bf5556d650fb9aa56a3ad6e6eec7575e87d472e8ab6d15eaef163d4";
          revision = "1";
          editedCabalFile = "1n8z1zcvrslsa9dvflx8528hsialmnljl1zzdjf1azs24xdq2npm";
          libraryHaskellDepends = [
            base
            bytestring
            deepseq
            text
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/lpsmith/blaze-builder";
          description = "Efficient buffered output";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      blaze-html = callPackage ({ base, blaze-builder, blaze-markup, bytestring, mkDerivation, stdenv, text }:
      mkDerivation {
          pname = "blaze-html";
          version = "0.8.1.3";
          sha256 = "8c16e717d353f981e0cd67b50f89ef6f94ab9c56662b3e58bd8a6c552433d637";
          libraryHaskellDepends = [
            base
            blaze-builder
            blaze-markup
            bytestring
            text
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://jaspervdj.be/blaze";
          description = "A blazingly fast HTML combinator library for Haskell";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      blaze-markup = callPackage ({ base, blaze-builder, bytestring, mkDerivation, stdenv, text }:
      mkDerivation {
          pname = "blaze-markup";
          version = "0.7.1.1";
          sha256 = "638da5984ecd5bcc87f5836786ff93352058a8856bea428d7ffd25bc26c54303";
          libraryHaskellDepends = [
            base
            blaze-builder
            bytestring
            text
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://jaspervdj.be/blaze";
          description = "A blazingly fast markup combinator library for Haskell";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      byteable = callPackage ({ base, bytestring, mkDerivation, stdenv }:
      mkDerivation {
          pname = "byteable";
          version = "0.1.1";
          sha256 = "243b34a1b5b64b39e39fe58f75c18f6cad5b668b10cabcd86816cbde27783fe2";
          enableSeparateDataOutput = true;
          libraryHaskellDepends = [
            base
            bytestring
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-byteable";
          description = "Type class for sequence of bytes";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      bytestring = callPackage ({ base, deepseq, ghc-prim, integer-gmp, mkDerivation, stdenv }:
      mkDerivation {
          pname = "bytestring";
          version = "0.10.6.0";
          sha256 = "271b9a6b7b81bc259f8a947b12354951829580b0fe0bd8482e41af261b118977";
          revision = "1";
          editedCabalFile = "0l0952852zm36r6zdsp6ynf5bfnaax8bbymbglhkbgqkb1w87dnn";
          libraryHaskellDepends = [
            base
            deepseq
            ghc-prim
            integer-gmp
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell/bytestring";
          description = "Fast, compact, strict and lazy byte strings with a list interface";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      cabal-doctest = callPackage ({ Cabal, base, directory, filepath, mkDerivation, stdenv }:
      mkDerivation {
          pname = "cabal-doctest";
          version = "1.0.6";
          sha256 = "decaaa5a73eaabaf3c4f8c644bd7f6e3f428b6244e935c0cf105f75f9b24ed2d";
          revision = "1";
          editedCabalFile = "1bk85avgc93yvcggwbk01fy8nvg6753wgmaanhkry0hz55h7mpld";
          libraryHaskellDepends = [
            base
            Cabal
            directory
            filepath
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/phadej/cabal-doctest";
          description = "A Setup.hs helper for doctests running";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      case-insensitive = callPackage ({ base, bytestring, deepseq, hashable, mkDerivation, stdenv, text }:
      mkDerivation {
          pname = "case-insensitive";
          version = "1.2.0.7";
          sha256 = "160d3898fd0d8b50bed820ff633e6292438f069adec5267c42b8bcf0f386cac8";
          libraryHaskellDepends = [
            base
            bytestring
            deepseq
            hashable
            text
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/basvandijk/case-insensitive";
          description = "Case insensitive string comparison";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      cereal = callPackage ({ array, base, bytestring, containers, ghc-prim, mkDerivation, stdenv }:
      mkDerivation {
          pname = "cereal";
          version = "0.5.2.0";
          sha256 = "b50e77ad340d672d0f2c53ce526a088ecdf74f1ed34f6bb2f95deab725dd2b14";
          libraryHaskellDepends = [
            array
            base
            bytestring
            containers
            ghc-prim
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/GaloisInc/cereal";
          description = "A binary serialization library";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      clock = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "clock";
          version = "0.7.2";
          sha256 = "886601978898d3a91412fef895e864576a7125d661e1f8abc49a2a08840e691f";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/corsis/clock";
          description = "High-resolution clock functions: monotonic, realtime, cputime";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      comonad = callPackage ({ base, containers, contravariant, distributive, mkDerivation, semigroups, stdenv, tagged, transformers, transformers-compat }:
      mkDerivation {
          pname = "comonad";
          version = "4.2.7.2";
          sha256 = "b762261ef545a16881b66409398752e249a8e654a34088c66d9fabf9ba5a3b2b";
          revision = "1";
          editedCabalFile = "03yfb6x9654x5bfhgx5rfvkfjnnvip6lm6malifpacjjghwi9lnb";
          libraryHaskellDepends = [
            base
            containers
            contravariant
            distributive
            semigroups
            tagged
            transformers
            transformers-compat
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/comonad/";
          description = "Comonads";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      conduit = callPackage ({ base, exceptions, lifted-base, mkDerivation, mmorph, monad-control, mtl, resourcet, stdenv, transformers, transformers-base }:
      mkDerivation {
          pname = "conduit";
          version = "1.2.8";
          sha256 = "80d5df4c70adf2b7e87138c55fba25e05be30eaef0c9a7926d97ae0c0cdb17fb";
          libraryHaskellDepends = [
            base
            exceptions
            lifted-base
            mmorph
            monad-control
            mtl
            resourcet
            transformers
            transformers-base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/snoyberg/conduit";
          description = "Streaming data processing library";
          license = stdenv.lib.licenses.mit;
        }) {};
      conduit-extra = callPackage ({ async, attoparsec, base, blaze-builder, bytestring, conduit, directory, exceptions, filepath, mkDerivation, monad-control, network, primitive, process, resourcet, stdenv, stm, streaming-commons, text, transformers, transformers-base }:
      mkDerivation {
          pname = "conduit-extra";
          version = "1.1.15";
          sha256 = "7bef29eb0db59c236519b0c5cac82183ed7741a535a57e0772aac1158e90bb8d";
          revision = "2";
          editedCabalFile = "0wz0g2mrrzdfr3ypr0h0q7i7r0my2dzyxi5fl58nx4as7kjcyhqx";
          libraryHaskellDepends = [
            async
            attoparsec
            base
            blaze-builder
            bytestring
            conduit
            directory
            exceptions
            filepath
            monad-control
            network
            primitive
            process
            resourcet
            stm
            streaming-commons
            text
            transformers
            transformers-base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/snoyberg/conduit";
          description = "Batteries included conduit: adapters for common libraries";
          license = stdenv.lib.licenses.mit;
        }) {};
      connection = callPackage ({ base, byteable, bytestring, containers, data-default-class, mkDerivation, network, socks, stdenv, tls, x509, x509-store, x509-system, x509-validation }:
      mkDerivation {
          pname = "connection";
          version = "0.2.7";
          sha256 = "46d452dc92ebc6e851a9f9ac01dd2d29df846795dfce039cf07ba7102a323235";
          libraryHaskellDepends = [
            base
            byteable
            bytestring
            containers
            data-default-class
            network
            socks
            tls
            x509
            x509-store
            x509-system
            x509-validation
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-connection";
          description = "Simple and easy network connections API";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      containers = callPackage ({ array, base, deepseq, ghc-prim, mkDerivation, stdenv }:
      mkDerivation {
          pname = "containers";
          version = "0.5.6.2";
          sha256 = "b1ade49f0f177c571052e7c7d7e8fa1d795c7192418be565db2df025ea8d2de5";
          revision = "1";
          editedCabalFile = "1z5i6xxkq88vwd0xir5nzqrg0ip665wagcivnnrchy8flypdvmyi";
          libraryHaskellDepends = [
            array
            base
            deepseq
            ghc-prim
          ];
          doHaddock = false;
          doCheck = false;
          description = "Assorted concrete container types";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      contravariant = callPackage ({ StateVar, base, mkDerivation, semigroups, stdenv, transformers, transformers-compat, void }:
      mkDerivation {
          pname = "contravariant";
          version = "1.4";
          sha256 = "e1666df1373ed784baa7d1e8e963bbc2d1f3c391578ac550ae74e7399173ee84";
          libraryHaskellDepends = [
            base
            semigroups
            StateVar
            transformers
            transformers-compat
            void
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/contravariant/";
          description = "Contravariant functors";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      cookie = callPackage ({ base, blaze-builder, bytestring, data-default-class, deepseq, mkDerivation, old-locale, stdenv, text, time }:
      mkDerivation {
          pname = "cookie";
          version = "0.4.2.1";
          sha256 = "06413091908e20ce154effdcd354d7eea1447380e29a8acdb15c3347512852e4";
          libraryHaskellDepends = [
            base
            blaze-builder
            bytestring
            data-default-class
            deepseq
            old-locale
            text
            time
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/snoyberg/cookie";
          description = "HTTP cookie parsing and rendering";
          license = stdenv.lib.licenses.mit;
        }) {};
      cryptonite = callPackage ({ base, bytestring, deepseq, ghc-prim, integer-gmp, memory, mkDerivation, stdenv }:
      mkDerivation {
          pname = "cryptonite";
          version = "0.21";
          sha256 = "639a66aee1c3fa64161b1886d319612b8ce92f751adde476fdc35aea730262ee";
          libraryHaskellDepends = [
            base
            bytestring
            deepseq
            ghc-prim
            integer-gmp
            memory
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell-crypto/cryptonite";
          description = "Cryptography Primitives sink";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      data-default-class = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "data-default-class";
          version = "0.0.1";
          sha256 = "adc8ee80a6f0e5903339a2b8685220b32bc3e23856d3c12186cc464ae5c88f31";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "A class for types with a default value";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      deepseq = callPackage ({ array, base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "deepseq";
          version = "1.4.1.1";
          sha256 = "908158eb30ac6abe2fb32d9c07cc2c3dae886867520b5529c09b5e87db32b3bf";
          revision = "1";
          editedCabalFile = "095j5l1p955ksmkr0fx7554kd96457g7ad61i2w619m03vh397db";
          libraryHaskellDepends = [
            array
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "Deep evaluation of data structures";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      directory = callPackage ({ base, filepath, mkDerivation, stdenv, time, unix }:
      mkDerivation {
          pname = "directory";
          version = "1.2.2.0";
          sha256 = "c4b720df1c098e7b58b3a99844106a3392b4bb5602c099850510b787483376b5";
          libraryHaskellDepends = [
            base
            filepath
            time
            unix
          ];
          doHaddock = false;
          doCheck = false;
          description = "Platform-agnostic library for filesystem operations";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      distributive = callPackage ({ base, base-orphans, mkDerivation, stdenv, tagged, transformers, transformers-compat }:
      mkDerivation {
          pname = "distributive";
          version = "0.5.1";
          sha256 = "8fd0968c19b00b64c8219b81903c72841494460fcf1c10e84fa44f321bb3ae92";
          revision = "2";
          editedCabalFile = "1582vsl6c89qwj6xadjg94pfih5sr1x9pcc14h5s9hbmvz59w794";
          libraryHaskellDepends = [
            base
            base-orphans
            tagged
            transformers
            transformers-compat
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/distributive/";
          description = "Distributive functors -- Dual to Traversable";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      dlist = callPackage ({ base, deepseq, mkDerivation, stdenv }:
      mkDerivation {
          pname = "dlist";
          version = "0.7.1.2";
          sha256 = "332d21f16fd30d2534b6ab96c98830a14266d8f368cff21f6a47469fb3493783";
          libraryHaskellDepends = [
            base
            deepseq
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/spl/dlist";
          description = "Difference lists";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      enclosed-exceptions = callPackage ({ base, deepseq, lifted-base, mkDerivation, monad-control, stdenv, transformers, transformers-base }:
      mkDerivation {
          pname = "enclosed-exceptions";
          version = "1.0.2";
          sha256 = "7b9beab82d219c0dd879dfdef70fb74a4a7595b4dbd0baf7adb12cdbbe8189f1";
          revision = "1";
          editedCabalFile = "0rjm8g2bm9a7qzklkp0rh5az4qh8nsl0hl119gjik671knygkdj0";
          libraryHaskellDepends = [
            base
            deepseq
            lifted-base
            monad-control
            transformers
            transformers-base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/jcristovao/enclosed-exceptions";
          description = "Catching all exceptions from within an enclosed computation";
          license = stdenv.lib.licenses.mit;
        }) {};
      exceptions = callPackage ({ base, mkDerivation, mtl, stdenv, stm, template-haskell, transformers, transformers-compat }:
      mkDerivation {
          pname = "exceptions";
          version = "0.8.3";
          sha256 = "4d6ad97e8e3d5dc6ce9ae68a469dc2fd3f66e9d312bc6faa7ab162eddcef87be";
          revision = "5";
          editedCabalFile = "1kfgp41i6mfz9gjczp3flvqxfhnznd81rwldv8j05807n6mnqqii";
          libraryHaskellDepends = [
            base
            mtl
            stm
            template-haskell
            transformers
            transformers-compat
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/exceptions/";
          description = "Extensible optionally-pure exceptions";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      extra = callPackage ({ base, directory, filepath, mkDerivation, process, stdenv, time, unix }:
      mkDerivation {
          pname = "extra";
          version = "1.4.10";
          sha256 = "b40b3f74c02e40697f4ba5242a764c2846921e8aafdd92e79a30a7afd9e56759";
          revision = "1";
          editedCabalFile = "1rp2hga7p4n4i4g8152jxx1my7l5bw7bhryjf205wga6hb4fw79p";
          libraryHaskellDepends = [
            base
            directory
            filepath
            process
            time
            unix
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/ndmitchell/extra#readme";
          description = "Extra functions I use";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      fail = callPackage ({ mkDerivation, stdenv }:
      mkDerivation {
          pname = "fail";
          version = "4.9.0.0";
          sha256 = "6d5cdb1a5c539425a9665f740e364722e1d9d6ae37fbc55f30fe3dbbbb91d4a2";
          doHaddock = false;
          doCheck = false;
          homepage = "https://prime.haskell.org/wiki/Libraries/Proposals/MonadFail";
          description = "Forward-compatible MonadFail class";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      filepath = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "filepath";
          version = "1.4.0.0";
          sha256 = "a43b3590476b1ca594ca108a4e8d4f8b0f0f5abb312666e6a42c24d8dd83b028";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell/filepath#readme";
          description = "Library for manipulating FilePaths in a cross platform way";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      foldl = callPackage ({ base, bytestring, comonad, containers, contravariant, mkDerivation, mwc-random, primitive, profunctors, stdenv, text, transformers, vector }:
      mkDerivation {
          pname = "foldl";
          version = "1.2.3";
          sha256 = "fb081168f7736a04dc68db348d2e0bc58d535da5ed74c4394a022dbaa46d3f25";
          libraryHaskellDepends = [
            base
            bytestring
            comonad
            containers
            contravariant
            mwc-random
            primitive
            profunctors
            text
            transformers
            vector
          ];
          doHaddock = false;
          doCheck = false;
          description = "Composable, streaming, and efficient left folds";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      ghc-prim = callPackage ({ mkDerivation, rts, stdenv }:
      mkDerivation {
          pname = "ghc-prim";
          version = "0.4.0.0";
          sha256 = "61688f073f20651000781e012da8c42e771b6f4a16bf62e03c263adf039d70f0";
          libraryHaskellDepends = [ rts ];
          doHaddock = false;
          doCheck = false;
          description = "GHC primitives";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      happy = callPackage ({ Cabal, array, base, containers, directory, filepath, mkDerivation, mtl, stdenv }:
      mkDerivation {
          pname = "happy";
          version = "1.19.9";
          sha256 = "3e81a3e813acca3aae52721c412cde18b7b7c71ecbacfaeaa5c2f4b35abf1d8d";
          revision = "2";
          editedCabalFile = "1zxi8zfwiwxidrhr0yj5srpzp32z66sld9xv0k4yz7046rkl3577";
          isLibrary = false;
          isExecutable = true;
          setupHaskellDepends = [
            base
            Cabal
            directory
            filepath
          ];
          executableHaskellDepends = [
            array
            base
            containers
            mtl
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://www.haskell.org/happy/";
          description = "Happy is a parser generator for Haskell";
          license = stdenv.lib.licenses.bsd2;
        }) {};
      hashable = callPackage ({ base, bytestring, ghc-prim, integer-gmp, mkDerivation, stdenv, text }:
      mkDerivation {
          pname = "hashable";
          version = "1.2.4.0";
          sha256 = "fb9671db0c39cd48d38e2e13e3352e2bf7dfa6341edfe68789a1753d21bb3cf3";
          libraryHaskellDepends = [
            base
            bytestring
            ghc-prim
            integer-gmp
            text
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/tibbe/hashable";
          description = "A class for types that can be converted to a hash value";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      hostname = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "hostname";
          version = "1.0";
          sha256 = "9b43dab1b6da521f35685b20555da00738c8e136eb972458c786242406a9cf5c";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "A very simple package providing a cross-platform means of determining the hostname";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      hourglass = callPackage ({ base, deepseq, mkDerivation, stdenv }:
      mkDerivation {
          pname = "hourglass";
          version = "0.2.10";
          sha256 = "d553362d7a6f7df60d8ff99304aaad0995be81f9d302725ebe9441829a0f8d80";
          libraryHaskellDepends = [
            base
            deepseq
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/vincenthz/hs-hourglass";
          description = "simple performant time related library";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      hscolour = callPackage ({ base, containers, mkDerivation, stdenv }:
      mkDerivation {
          pname = "hscolour";
          version = "1.24.4";
          sha256 = "243332b082294117f37b2c2c68079fa61af68b36223b3fc07594f245e0e5321d";
          isLibrary = true;
          isExecutable = true;
          enableSeparateDataOutput = true;
          libraryHaskellDepends = [
            base
            containers
          ];
          executableHaskellDepends = [
            base
            containers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://code.haskell.org/~malcolm/hscolour/";
          description = "Colourise Haskell code";
          license = "LGPL";
        }) {};
      http-client = callPackage ({ array, base, base64-bytestring, blaze-builder, bytestring, case-insensitive, containers, cookie, data-default-class, deepseq, exceptions, filepath, ghc-prim, http-types, mime-types, mkDerivation, network, network-uri, random, stdenv, streaming-commons, text, time, transformers }:
      mkDerivation {
          pname = "http-client";
          version = "0.4.31.2";
          sha256 = "16410148a9705677cdd89510192caf1abd3460db2a17ce0c2fafd7bd0c15d88b";
          libraryHaskellDepends = [
            array
            base
            base64-bytestring
            blaze-builder
            bytestring
            case-insensitive
            containers
            cookie
            data-default-class
            deepseq
            exceptions
            filepath
            ghc-prim
            http-types
            mime-types
            network
            network-uri
            random
            streaming-commons
            text
            time
            transformers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/snoyberg/http-client";
          description = "An HTTP client engine, intended as a base layer for more user-friendly packages";
          license = stdenv.lib.licenses.mit;
        }) {};
      http-client-tls = callPackage ({ base, bytestring, connection, data-default-class, http-client, mkDerivation, network, stdenv, tls }:
      mkDerivation {
          pname = "http-client-tls";
          version = "0.2.4.1";
          sha256 = "8dc85884e15cd32f59a47e11861d78566c6ccb202e8d317403b784278f628ba3";
          revision = "1";
          editedCabalFile = "0v7mb10cq7j6f1a0rli8wp5gmk06zx218ly4wzyg97a43g7v1w96";
          libraryHaskellDepends = [
            base
            bytestring
            connection
            data-default-class
            http-client
            network
            tls
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/snoyberg/http-client";
          description = "http-client backend using the connection package and tls library";
          license = stdenv.lib.licenses.mit;
        }) {};
      http-conduit = callPackage ({ aeson, base, bytestring, conduit, conduit-extra, data-default-class, exceptions, http-client, http-client-tls, http-types, lifted-base, mkDerivation, monad-control, mtl, resourcet, stdenv, transformers }:
      mkDerivation {
          pname = "http-conduit";
          version = "2.1.11";
          sha256 = "75df5c0515080a09b4cdc73a759523b10265a692ff50beb964766d4f8dcf0d7f";
          libraryHaskellDepends = [
            aeson
            base
            bytestring
            conduit
            conduit-extra
            data-default-class
            exceptions
            http-client
            http-client-tls
            http-types
            lifted-base
            monad-control
            mtl
            resourcet
            transformers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://www.yesodweb.com/book/http-conduit";
          description = "HTTP client package with conduit interface and HTTPS support";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      http-types = callPackage ({ array, base, blaze-builder, bytestring, case-insensitive, mkDerivation, stdenv, text }:
      mkDerivation {
          pname = "http-types";
          version = "0.9.1";
          sha256 = "7bed648cdc1c69e76bf039763dbe1074b55fd2704911dd0cb6b7dfebf1b6f550";
          libraryHaskellDepends = [
            array
            base
            blaze-builder
            bytestring
            case-insensitive
            text
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/aristidb/http-types";
          description = "Generic HTTP types for Haskell (for both client and server code)";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      integer-gmp = callPackage ({ ghc-prim, mkDerivation, stdenv }:
      mkDerivation {
          pname = "integer-gmp";
          version = "1.0.0.0";
          sha256 = "ae1489ea4361138f668aee76c5ac47bfc1818ac1ef2832525fe09f15970e006a";
          revision = "1";
          editedCabalFile = "0qsnmvn70lvcivx3sn5pqaxfya0j6q6dq6qm7mqlwjy9lywzlqsx";
          libraryHaskellDepends = [
            ghc-prim
          ];
          doHaddock = false;
          doCheck = false;
          description = "Integer library based on GMP";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      iridium = callPackage ({ Cabal, ansi-terminal, base, bytestring, containers, extra, foldl, http-conduit, lifted-base, mkDerivation, monad-control, multistate, process, split, stdenv, system-filepath, tagged, text, transformers, transformers-base, turtle, unordered-containers, vector, xmlhtml, yaml }:
      mkDerivation {
          pname = "iridium";
          version = "0.1.5.7";
          sha256 = "0jfsz8j9dq0nfr536wp78k02ffg8xgjm3zqgjgfdm1i0zwi5dcbp";
          isLibrary = true;
          isExecutable = true;
          enableSeparateDataOutput = true;
          libraryHaskellDepends = [
            ansi-terminal
            base
            bytestring
            Cabal
            containers
            extra
            foldl
            http-conduit
            lifted-base
            monad-control
            multistate
            process
            split
            system-filepath
            tagged
            text
            transformers
            transformers-base
            turtle
            unordered-containers
            vector
            xmlhtml
            yaml
          ];
          executableHaskellDepends = [
            base
            extra
            multistate
            text
            transformers
            unordered-containers
            yaml
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/lspitzner/iridium";
          description = "Automated Local Cabal Package Testing and Uploading";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      jailbreak-cabal = callPackage ({ Cabal, base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "jailbreak-cabal";
          version = "1.3.3";
          sha256 = "6bac08ad1a1ff7452a2963272f96f5de0a3df200fb3219dde6ee93e4963dd01c";
          isLibrary = false;
          isExecutable = true;
          executableHaskellDepends = [
            base
            Cabal
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/peti/jailbreak-cabal#readme";
          description = "Strip version restrictions from Cabal files";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      lifted-base = callPackage ({ base, mkDerivation, monad-control, stdenv, transformers-base }:
      mkDerivation {
          pname = "lifted-base";
          version = "0.2.3.8";
          sha256 = "1605df810bc941951522d0cd1b777ff1d62dac6628aabed165a49b848f25df9f";
          libraryHaskellDepends = [
            base
            monad-control
            transformers-base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/basvandijk/lifted-base";
          description = "lifted IO operations from the base library";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      managed = callPackage ({ base, mkDerivation, stdenv, transformers }:
      mkDerivation {
          pname = "managed";
          version = "1.0.5";
          sha256 = "b9c99943dadaa730ea3d889a09c3ca0efa1b7728f2bb0854815d49f40d4772e0";
          libraryHaskellDepends = [
            base
            transformers
          ];
          doHaddock = false;
          doCheck = false;
          description = "A monad for managed values";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      memory = callPackage ({ base, bytestring, deepseq, ghc-prim, mkDerivation, stdenv }:
      mkDerivation {
          pname = "memory";
          version = "0.13";
          sha256 = "dc73602573eaed85b1887f07057151c7de63f559ef90a10297c363d9b120870a";
          revision = "1";
          editedCabalFile = "0dvbc82nnnrlbw1n5kq6gld81cl79yzxm28npnlz0j181dyrcwvr";
          libraryHaskellDepends = [
            base
            bytestring
            deepseq
            ghc-prim
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/vincenthz/hs-memory";
          description = "memory and related abstraction stuff";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      mime-types = callPackage ({ base, bytestring, containers, mkDerivation, stdenv, text }:
      mkDerivation {
          pname = "mime-types";
          version = "0.1.0.7";
          sha256 = "83164a24963a7ef37543349df095155b30116c208e602a159a5cd3722f66e9b9";
          libraryHaskellDepends = [
            base
            bytestring
            containers
            text
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/yesodweb/wai";
          description = "Basic mime-type handling types and functions";
          license = stdenv.lib.licenses.mit;
        }) {};
      mmorph = callPackage ({ base, mkDerivation, mtl, stdenv, transformers, transformers-compat }:
      mkDerivation {
          pname = "mmorph";
          version = "1.0.6";
          sha256 = "14c391b111af4cc10917a9340897ae2a5718f5b0b7e6bc13f379445c58fe0dc5";
          revision = "1";
          editedCabalFile = "081g39qv8lzmavv8q4sr24liiy56fwrbngyg7j67ah1zgwld8ss8";
          libraryHaskellDepends = [
            base
            mtl
            transformers
            transformers-compat
          ];
          doHaddock = false;
          doCheck = false;
          description = "Monad morphisms";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      monad-control = callPackage ({ base, mkDerivation, stdenv, stm, transformers, transformers-base, transformers-compat }:
      mkDerivation {
          pname = "monad-control";
          version = "1.0.1.0";
          sha256 = "d4b0209c6cb7006fac618e4d8e3743d908f8b21579d6ff72e9f6e758e24301f4";
          libraryHaskellDepends = [
            base
            stm
            transformers
            transformers-base
            transformers-compat
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/basvandijk/monad-control";
          description = "Lift control operations, like exception catching, through monad transformers";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      mtl = callPackage ({ base, mkDerivation, stdenv, transformers }:
      mkDerivation {
          pname = "mtl";
          version = "2.2.1";
          sha256 = "cae59d79f3a16f8e9f3c9adc1010c7c6cdddc73e8a97ff4305f6439d855c8dc5";
          revision = "1";
          editedCabalFile = "0fsa965g9h23mlfjzghmmhcb9dmaq8zpm374gby6iwgdx47q0njb";
          libraryHaskellDepends = [
            base
            transformers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/mtl";
          description = "Monad classes, using functional dependencies";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      multistate = callPackage ({ base, mkDerivation, monad-control, mtl, stdenv, tagged, transformers, transformers-base }:
      mkDerivation {
          pname = "multistate";
          version = "0.7.1.1";
          sha256 = "609650cbbfd102c775b44be3fd7bb4f6732127e64b21dd45ea1af057c5ffb8a6";
          revision = "1";
          editedCabalFile = "0fz1gbiv0fdbmng6kinj3pzc3s6w06lgqgriln5lzrqrp4g5ggd5";
          isLibrary = true;
          isExecutable = true;
          libraryHaskellDepends = [
            base
            monad-control
            mtl
            tagged
            transformers
            transformers-base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/lspitzner/multistate";
          description = "like mtl's ReaderT / WriterT / StateT, but more than one contained value/type";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      mwc-random = callPackage ({ base, mkDerivation, primitive, stdenv, time, vector }:
      mkDerivation {
          pname = "mwc-random";
          version = "0.13.5.0";
          sha256 = "28dd2d95d088438ab15e9dee45ddc500b6c4700a87539c70a48b1b7b4c8d1ca9";
          libraryHaskellDepends = [
            base
            primitive
            time
            vector
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/bos/mwc-random";
          description = "Fast, high quality pseudo random number generation";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      network = callPackage ({ base, bytestring, mkDerivation, stdenv, unix }:
      mkDerivation {
          pname = "network";
          version = "2.6.3.1";
          sha256 = "57045f5e2bedc095670182130a6d1134fcc65d097824ac5b03933876067d82e6";
          libraryHaskellDepends = [
            base
            bytestring
            unix
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell/network";
          description = "Low-level networking interface";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      network-uri = callPackage ({ base, deepseq, mkDerivation, parsec, stdenv }:
      mkDerivation {
          pname = "network-uri";
          version = "2.6.1.0";
          sha256 = "423e0a2351236f3fcfd24e39cdbc38050ec2910f82245e69ca72a661f7fc47f0";
          revision = "1";
          editedCabalFile = "141nj7q0p9wkn5gr41ayc63cgaanr9m59yym47wpxqr3c334bk32";
          libraryHaskellDepends = [
            base
            deepseq
            parsec
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell/network-uri";
          description = "URI manipulation";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      old-locale = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "old-locale";
          version = "1.0.0.7";
          sha256 = "dbaf8bf6b888fb98845705079296a23c3f40ee2f449df7312f7f7f1de18d7b50";
          revision = "2";
          editedCabalFile = "04b9vn007hlvsrx4ksd3r8r3kbyaj2kvwxchdrmd4370qzi8p6gs";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "locale library";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      optional-args = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "optional-args";
          version = "1.0.1";
          sha256 = "940604d6ebc1fb1b5372cb21e0b3870cd9d920655e41841844131994d1f1fd99";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "Optional function arguments";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      optparse-applicative = callPackage ({ ansi-wl-pprint, base, mkDerivation, process, stdenv, transformers, transformers-compat }:
      mkDerivation {
          pname = "optparse-applicative";
          version = "0.13.1.0";
          sha256 = "f1fcf9d7e78ddf14083a07d8fe1aa65d75c5102e0d44df981585bce54c5c2a2b";
          libraryHaskellDepends = [
            ansi-wl-pprint
            base
            process
            transformers
            transformers-compat
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/pcapriotti/optparse-applicative";
          description = "Utilities and combinators for parsing command line options";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      parsec = callPackage ({ base, bytestring, mkDerivation, mtl, stdenv, text }:
      mkDerivation {
          pname = "parsec";
          version = "3.1.11";
          sha256 = "6f87251cb1d11505e621274dec15972de924a9074f07f7430a18892064c2676e";
          revision = "1";
          editedCabalFile = "0prqjj2gxlwh2qhpcck5k6cgk4har9xqxc67yzjqd44mr2xgl7ir";
          libraryHaskellDepends = [
            base
            bytestring
            mtl
            text
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/aslatter/parsec";
          description = "Monadic parser combinators";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      pem = callPackage ({ base, base64-bytestring, bytestring, mkDerivation, mtl, stdenv }:
      mkDerivation {
          pname = "pem";
          version = "0.2.2";
          sha256 = "372808c76c6d860aedb4e30171cb4ee9f6154d9f68e3f2310f820bf174995a98";
          enableSeparateDataOutput = true;
          libraryHaskellDepends = [
            base
            base64-bytestring
            bytestring
            mtl
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-pem";
          description = "Privacy Enhanced Mail (PEM) format reader and writer";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      pretty = callPackage ({ base, deepseq, ghc-prim, mkDerivation, stdenv }:
      mkDerivation {
          pname = "pretty";
          version = "1.1.2.0";
          sha256 = "7c29474eee89894ddb6b1c88820500bce0af1e4e79f459a80ae546c905657310";
          revision = "1";
          editedCabalFile = "0jq9lq4i4dpwpgl12py9h1fixcml477vca5ak4gn1brl547bgvvp";
          libraryHaskellDepends = [
            base
            deepseq
            ghc-prim
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/haskell/pretty";
          description = "Pretty-printing library";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      primitive = callPackage ({ base, ghc-prim, mkDerivation, stdenv, transformers }:
      mkDerivation {
          pname = "primitive";
          version = "0.6.1.0";
          sha256 = "93731fa72eaf74e8e83453f080828e18cec9fbc82bee91b49ba8b61c043d38c8";
          revision = "1";
          editedCabalFile = "0gb8lcn6bd6ilfln7ah9jmqq6324vgkrgdsnz1qvlyj3bi2w5ivf";
          libraryHaskellDepends = [
            base
            ghc-prim
            transformers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell/primitive";
          description = "Primitive memory-related operations";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      process = callPackage ({ base, deepseq, directory, filepath, mkDerivation, stdenv, unix }:
      mkDerivation {
          pname = "process";
          version = "1.2.3.0";
          sha256 = "619e04157183631bd16fa921589bd4125b7db12c45287e962a7b8402a70d60c5";
          libraryHaskellDepends = [
            base
            deepseq
            directory
            filepath
            unix
          ];
          doHaddock = false;
          doCheck = false;
          description = "Process libraries";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      profunctors = callPackage ({ base, base-orphans, bifunctors, comonad, contravariant, distributive, mkDerivation, stdenv, tagged, transformers }:
      mkDerivation {
          pname = "profunctors";
          version = "5.2";
          sha256 = "87a7e25c4745ea8ff479dd1212ec2e57710abb3d3dd30f948fa16be1d3ee05a4";
          revision = "1";
          editedCabalFile = "1q0zva60kqb560fr0ii0gm227sg6q7ddbhriv64l6nfv509vw32k";
          libraryHaskellDepends = [
            base
            base-orphans
            bifunctors
            comonad
            contravariant
            distributive
            tagged
            transformers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/profunctors/";
          description = "Profunctors";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      random = callPackage ({ base, mkDerivation, stdenv, time }:
      mkDerivation {
          pname = "random";
          version = "1.1";
          sha256 = "b718a41057e25a3a71df693ab0fe2263d492e759679b3c2fea6ea33b171d3a5a";
          revision = "1";
          editedCabalFile = "1pv5d7bm2rgap7llp5vjsplrg048gvf0226y0v19gpvdsx7n4rvv";
          libraryHaskellDepends = [
            base
            time
          ];
          doHaddock = false;
          doCheck = false;
          description = "random number library";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      resourcet = callPackage ({ base, containers, exceptions, lifted-base, mkDerivation, mmorph, monad-control, mtl, stdenv, transformers, transformers-base, transformers-compat }:
      mkDerivation {
          pname = "resourcet";
          version = "1.1.9";
          sha256 = "5a1999d26b896603cab8121b77f36723dc50960291872b691ff4a9533e162ef5";
          libraryHaskellDepends = [
            base
            containers
            exceptions
            lifted-base
            mmorph
            monad-control
            mtl
            transformers
            transformers-base
            transformers-compat
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/snoyberg/conduit";
          description = "Deterministic allocation and freeing of scarce resources";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      scientific = callPackage ({ base, binary, bytestring, containers, deepseq, ghc-prim, hashable, integer-gmp, mkDerivation, stdenv, text, vector }:
      mkDerivation {
          pname = "scientific";
          version = "0.3.4.9";
          sha256 = "108330662b0af9a04d7da55864211ce12008efe36614d897ba635e80670918a8";
          revision = "1";
          editedCabalFile = "0q8xnyyyl4llmfi0ph7cxi7cqyq3v8w7am027in39ir2wrh5jgw3";
          libraryHaskellDepends = [
            base
            binary
            bytestring
            containers
            deepseq
            ghc-prim
            hashable
            integer-gmp
            text
            vector
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/basvandijk/scientific";
          description = "Numbers represented using scientific notation";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      semigroups = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "semigroups";
          version = "0.18.2";
          sha256 = "5dc9ff8622af25412fb071098063da288cd408a844e67c3371b78daa86d5d0e4";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/semigroups/";
          description = "Anything that associates";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      socks = callPackage ({ base, bytestring, cereal, mkDerivation, network, stdenv }:
      mkDerivation {
          pname = "socks";
          version = "0.5.5";
          sha256 = "2647ea93e21ad1dfd77e942c022c8707e468d25e1ff672a88be82508034fc868";
          revision = "1";
          editedCabalFile = "0nz8q0xvd8y6f42bd1w3q8d8bg1qzl8ggx0a23kb3jb60g36dmvw";
          libraryHaskellDepends = [
            base
            bytestring
            cereal
            network
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-socks";
          description = "Socks proxy (version 5) implementation";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      split = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "split";
          version = "0.2.3.1";
          sha256 = "7615b60adee20c19ddafd9d74456e8fe8e4274e2c676a5e858511b664205c688";
          revision = "1";
          editedCabalFile = "1kbf588dpzivh8fzrfgs761i4pqzcnpn8di7zxnq0ir9lwhfk2b0";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "Combinator library for splitting lists";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      stm = callPackage ({ array, base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "stm";
          version = "2.4.4.1";
          sha256 = "8f999095ed8d50d2056fc6e185035ee8166c50751e1af8de02ac38d382bf3384";
          revision = "1";
          editedCabalFile = "0kzw4rw9fgmc4qyxmm1lwifdyrx5r1356150xm14vy4mp86diks9";
          libraryHaskellDepends = [
            array
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "Software Transactional Memory";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      streaming-commons = callPackage ({ array, async, base, blaze-builder, bytestring, directory, mkDerivation, network, process, random, stdenv, stm, text, transformers, unix, zlib }:
      mkDerivation {
          pname = "streaming-commons";
          version = "0.1.17";
          sha256 = "e50a38cb8b626ef2f031c195e22171ffce00e20cbe63e8c768887564a7f47da9";
          libraryHaskellDepends = [
            array
            async
            base
            blaze-builder
            bytestring
            directory
            network
            process
            random
            stm
            text
            transformers
            unix
            zlib
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/fpco/streaming-commons";
          description = "Common lower-level functions needed by various streaming data libraries";
          license = stdenv.lib.licenses.mit;
        }) {};
      stringbuilder = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "stringbuilder";
          version = "0.5.1";
          sha256 = "d878bdc4da806dbce5ab684ef13d2634c17c15b991d0ed3bb25a331eba6603ba";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "A writer monad for multi-line string literals";
          license = stdenv.lib.licenses.mit;
        }) {};
      syb = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "syb";
          version = "0.6";
          sha256 = "a38d1f7e6a40e2c990fec85215c45063a508bf73df98a4483ec78c5025b66cdc";
          revision = "1";
          editedCabalFile = "158ngdnlq9n1mil7cq2bzy4zkgx73zzms9q56wp6ll93m5mc4nlx";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://www.cs.uu.nl/wiki/GenericProgramming/SYB";
          description = "Scrap Your Boilerplate";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      system-fileio = callPackage ({ base, bytestring, mkDerivation, stdenv, system-filepath, text, time, unix }:
      mkDerivation {
          pname = "system-fileio";
          version = "0.3.16.3";
          sha256 = "3175707cb322c65760fa2eb2ab17327f251c8294ad688efc6258e82328830491";
          libraryHaskellDepends = [
            base
            bytestring
            system-filepath
            text
            time
            unix
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/fpco/haskell-filesystem";
          description = "Consistent filesystem interaction across GHC versions (deprecated)";
          license = stdenv.lib.licenses.mit;
        }) {};
      system-filepath = callPackage ({ base, bytestring, deepseq, mkDerivation, stdenv, text }:
      mkDerivation {
          pname = "system-filepath";
          version = "0.4.13.4";
          sha256 = "345d7dec968b74ab1b8c0e7bb78c2ef1e5be7be6b7bac455340fd658abfec5fb";
          libraryHaskellDepends = [
            base
            bytestring
            deepseq
            text
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/fpco/haskell-filesystem";
          description = "High-level, byte-based file and directory path manipulations (deprecated)";
          license = stdenv.lib.licenses.mit;
        }) {};
      tagged = callPackage ({ base, deepseq, mkDerivation, stdenv, template-haskell }:
      mkDerivation {
          pname = "tagged";
          version = "0.8.4";
          sha256 = "20c861d299445ea810ba39d9d0529fb0b3862f4d0271a4fb168ccd493a234d5e";
          libraryHaskellDepends = [
            base
            deepseq
            template-haskell
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/tagged";
          description = "Haskell 98 phantom types to avoid unsafely passing dummy arguments";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      template-haskell = callPackage ({ base, mkDerivation, pretty, stdenv }:
      mkDerivation {
          pname = "template-haskell";
          version = "2.10.0.0";
          sha256 = "358a3818d04fde27dd44f2c6d24b409031839ee5da2c9ec34b16257fd78c0df8";
          libraryHaskellDepends = [
            base
            pretty
          ];
          doHaddock = false;
          doCheck = false;
          description = "Support library for Template Haskell";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      temporary = callPackage ({ base, directory, exceptions, filepath, mkDerivation, stdenv, transformers, unix }:
      mkDerivation {
          pname = "temporary";
          version = "1.2.0.4";
          sha256 = "51e713804246404df8a728919a2e7d1994f8cfda42cfa7a74ea65d8b7d206762";
          libraryHaskellDepends = [
            base
            directory
            exceptions
            filepath
            transformers
            unix
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://www.github.com/feuerbach/temporary";
          description = "Portable temporary file and directory support for Windows and Unix, based on code from Cabal";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      text = callPackage ({ array, base, binary, bytestring, deepseq, ghc-prim, integer-gmp, mkDerivation, stdenv }:
      mkDerivation {
          pname = "text";
          version = "1.2.2.1";
          sha256 = "1addb1bdf36293c996653c9a0a320b5491714495862d997a23fb1ecd41ff395b";
          revision = "1";
          editedCabalFile = "1y9v539ngplrpnw1wd3wvazxqb90iwxivnlzrhaljryijp9zlvqw";
          libraryHaskellDepends = [
            array
            base
            binary
            bytestring
            deepseq
            ghc-prim
            integer-gmp
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/bos/text";
          description = "An efficient packed Unicode text type";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      time = callPackage ({ base, deepseq, mkDerivation, stdenv }:
      mkDerivation {
          pname = "time";
          version = "1.5.0.1";
          sha256 = "24a1cc077b0300d69401d08dfc8895b0199ebd003a9a0eb8845250dd2aebd14e";
          revision = "1";
          editedCabalFile = "0pv1bkv0x8hw6qszj7sjg1g8hms6hsb6c3dz9h8ypbadcb85v829";
          libraryHaskellDepends = [
            base
            deepseq
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell/time";
          description = "A time library";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      tls = callPackage ({ asn1-encoding, asn1-types, async, base, bytestring, cereal, cryptonite, data-default-class, memory, mkDerivation, mtl, network, stdenv, transformers, x509, x509-store, x509-validation }:
      mkDerivation {
          pname = "tls";
          version = "1.3.9";
          sha256 = "81355e16528796d3097719e74f7f1f8cae50daed06926d1995731bab8e02267b";
          libraryHaskellDepends = [
            asn1-encoding
            asn1-types
            async
            base
            bytestring
            cereal
            cryptonite
            data-default-class
            memory
            mtl
            network
            transformers
            x509
            x509-store
            x509-validation
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-tls";
          description = "TLS/SSL protocol native implementation (Server and Client)";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      transformers = callPackage ({ base, mkDerivation, stdenv }:
      mkDerivation {
          pname = "transformers";
          version = "0.4.2.0";
          sha256 = "79565425178a8e349fc6e100d3def6447b8d9014ba1206fc85f584cadc276628";
          revision = "1";
          editedCabalFile = "1q7y5mh3bxrnxinkvgwyssgrbbl4pp183ncww8dwzgsplf0zav0n";
          libraryHaskellDepends = [
            base
          ];
          doHaddock = false;
          doCheck = false;
          description = "Concrete functor and monad transformers";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      transformers-base = callPackage ({ base, mkDerivation, stdenv, stm, transformers, transformers-compat }:
      mkDerivation {
          pname = "transformers-base";
          version = "0.4.4";
          sha256 = "6aa3494fc70659342fbbb163035d5827ecfd8079e3c929e2372adf771fd52387";
          revision = "1";
          editedCabalFile = "196pr3a4lhgklyw6nq6rv1j9djwzmvx7xrpp58carxnb55gk06pv";
          libraryHaskellDepends = [
            base
            stm
            transformers
            transformers-compat
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/mvv/transformers-base";
          description = "Lift computations from the bottom of a transformer stack";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      transformers-compat = callPackage ({ base, mkDerivation, stdenv, transformers }:
      mkDerivation {
          pname = "transformers-compat";
          version = "0.4.0.4";
          sha256 = "d5231bc9929ed234032411038c0baae5a3d82939163c2a36582fbe657c46af52";
          libraryHaskellDepends = [
            base
            transformers
          ];
          patchPhase = ''
            ghc-pkg list | grep transformers
          '';
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/transformers-compat/";
          description = "A small compatibility shim exposing the new types from transformers 0.3 and 0.4 to older Haskell platforms.";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      turtle = callPackage ({ ansi-wl-pprint, async, base, bytestring, clock, directory, foldl, hostname, managed, mkDerivation, optional-args, optparse-applicative, process, stdenv, stm, system-fileio, system-filepath, temporary, text, time, transformers, unix, unix-compat }:
      mkDerivation {
          pname = "turtle";
          version = "1.3.1";
          sha256 = "233d05f8d73d171278be765872d623e56f1d795234a94d33a57f1bcca98edd5e";
          libraryHaskellDepends = [
            ansi-wl-pprint
            async
            base
            bytestring
            clock
            directory
            foldl
            hostname
            managed
            optional-args
            optparse-applicative
            process
            stm
            system-fileio
            system-filepath
            temporary
            text
            time
            transformers
            unix
            unix-compat
          ];
          doHaddock = false;
          doCheck = false;
          description = "Shell programming, Haskell-style";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      unix = callPackage ({ base, bytestring, mkDerivation, stdenv, time }:
      mkDerivation {
          pname = "unix";
          version = "2.7.1.0";
          sha256 = "6bd4e6013855541535a1317197aa6a11e7f24ba0e4dd64a8b7fcfd40b5a4e45c";
          revision = "1";
          editedCabalFile = "00nqyvc34cn73gd829cl2cfkg6c3jb6qdrwf3ssz0l4d2apk4cpf";
          libraryHaskellDepends = [
            base
            bytestring
            time
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell/unix";
          description = "POSIX functionality";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      unix-compat = callPackage ({ base, mkDerivation, stdenv, unix }:
      mkDerivation {
          pname = "unix-compat";
          version = "0.4.1.4";
          sha256 = "fafa1a9eefc93287c028cc61f17a91f886f164b3f64392f1756f8a7f8b3cb34b";
          revision = "2";
          editedCabalFile = "170j8a6dp825iwmk4v34pgi7c6pmkcjcrip5vznkxvdsjxagp71c";
          libraryHaskellDepends = [
            base
            unix
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/jystic/unix-compat";
          description = "Portable POSIX-compatibility layer";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      unordered-containers = callPackage ({ base, deepseq, hashable, mkDerivation, stdenv }:
      mkDerivation {
          pname = "unordered-containers";
          version = "0.2.7.2";
          sha256 = "7f5c4344fcab01f6046378c64522f0dfd69e417f6c1a8858a24bdabaadb3e56e";
          revision = "1";
          editedCabalFile = "124apmss1pqgvpsvivg7211m7np2mi2p2zs1v80b5y57xwmj5hhh";
          libraryHaskellDepends = [
            base
            deepseq
            hashable
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/tibbe/unordered-containers";
          description = "Efficient hashing-based container types";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      vector = callPackage ({ base, deepseq, ghc-prim, mkDerivation, primitive, stdenv }:
      mkDerivation {
          pname = "vector";
          version = "0.11.0.0";
          sha256 = "0a5320ed44c3f2b04b7f61e0f63f4fcd5b337524e601e01d5813ace3f5a432e4";
          revision = "2";
          editedCabalFile = "1kjafhgsyjqlvrpfv2vj17hipyv0zw56a2kbl6khzn5li9szvyib";
          libraryHaskellDepends = [
            base
            deepseq
            ghc-prim
            primitive
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/haskell/vector";
          description = "Efficient Arrays";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      void = callPackage ({ base, deepseq, ghc-prim, hashable, mkDerivation, semigroups, stdenv }:
      mkDerivation {
          pname = "void";
          version = "0.7.1";
          sha256 = "c9f0fd93680c029abb9654b5464be260652829961b18b7046f96a0df95e825f4";
          libraryHaskellDepends = [
            base
            deepseq
            ghc-prim
            hashable
            semigroups
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/ekmett/void";
          description = "A Haskell 98 logically uninhabited data type";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      x509 = callPackage ({ asn1-encoding, asn1-parse, asn1-types, base, bytestring, containers, cryptonite, hourglass, memory, mkDerivation, mtl, pem, stdenv }:
      mkDerivation {
          pname = "x509";
          version = "1.6.5";
          sha256 = "b53894214e23ab2795f2a9f4c885e37b35a223bbc03763b0017ce06dc8394783";
          libraryHaskellDepends = [
            asn1-encoding
            asn1-parse
            asn1-types
            base
            bytestring
            containers
            cryptonite
            hourglass
            memory
            mtl
            pem
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-certificate";
          description = "X509 reader and writer";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      x509-store = callPackage ({ asn1-encoding, asn1-types, base, bytestring, containers, cryptonite, directory, filepath, mkDerivation, mtl, pem, stdenv, x509 }:
      mkDerivation {
          pname = "x509-store";
          version = "1.6.2";
          sha256 = "49fd261c7e55a45fd357931a6d9f81e22f242e6047304d3e2662e43db94d807b";
          libraryHaskellDepends = [
            asn1-encoding
            asn1-types
            base
            bytestring
            containers
            cryptonite
            directory
            filepath
            mtl
            pem
            x509
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-certificate";
          description = "X.509 collection accessing and storing methods";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      x509-system = callPackage ({ base, bytestring, containers, directory, filepath, mkDerivation, mtl, pem, process, stdenv, x509, x509-store }:
      mkDerivation {
          pname = "x509-system";
          version = "1.6.4";
          sha256 = "d98ef028855ad73a872ed86026f205aba383378bf1e63462c5d3e4733b60ff4c";
          libraryHaskellDepends = [
            base
            bytestring
            containers
            directory
            filepath
            mtl
            pem
            process
            x509
            x509-store
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-certificate";
          description = "Handle per-operating-system X.509 accessors and storage";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      x509-validation = callPackage ({ asn1-encoding, asn1-types, base, byteable, bytestring, containers, cryptonite, data-default-class, hourglass, memory, mkDerivation, mtl, pem, stdenv, x509, x509-store }:
      mkDerivation {
          pname = "x509-validation";
          version = "1.6.5";
          sha256 = "d1f73197677b6d19795fc80e4a1fa93e810d567ee4e3edc74e841b3eb20e1ca4";
          libraryHaskellDepends = [
            asn1-encoding
            asn1-types
            base
            byteable
            bytestring
            containers
            cryptonite
            data-default-class
            hourglass
            memory
            mtl
            pem
            x509
            x509-store
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/vincenthz/hs-certificate";
          description = "X.509 Certificate and CRL validation";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      xmlhtml = callPackage ({ base, blaze-builder, blaze-html, blaze-markup, bytestring, containers, mkDerivation, parsec, stdenv, text, unordered-containers }:
      mkDerivation {
          pname = "xmlhtml";
          version = "0.2.3.5";
          sha256 = "e333a1c7afd5068b60b143457fea7325a34408cc65b3ac55f5b342eb0274b06d";
          revision = "4";
          editedCabalFile = "073a98mmczjb80bjblzwcybnidchj9vgivcj6b5rdvh584iwbhz2";
          libraryHaskellDepends = [
            base
            blaze-builder
            blaze-html
            blaze-markup
            bytestring
            containers
            parsec
            text
            unordered-containers
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "https://github.com/snapframework/xmlhtml";
          description = "XML parser and renderer with HTML 5 quirks mode";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      yaml = callPackage ({ aeson, attoparsec, base, bytestring, conduit, containers, directory, enclosed-exceptions, filepath, libyaml, mkDerivation, resourcet, scientific, semigroups, stdenv, template-haskell, text, transformers, unordered-containers, vector }:
      mkDerivation {
          pname = "yaml";
          version = "0.8.21.2";
          sha256 = "441cf712cd20ac6b0ded900562ca33770c8752702963ab267bff72b0657fef29";
          configureFlags = [
            "-fsystem-libyaml"
          ];
          isLibrary = true;
          isExecutable = true;
          libraryHaskellDepends = [
            aeson
            attoparsec
            base
            bytestring
            conduit
            containers
            directory
            enclosed-exceptions
            filepath
            resourcet
            scientific
            semigroups
            template-haskell
            text
            transformers
            unordered-containers
            vector
          ];
          libraryPkgconfigDepends = [
            libyaml
          ];
          executableHaskellDepends = [
            aeson
            base
            bytestring
          ];
          doHaddock = false;
          doCheck = false;
          homepage = "http://github.com/snoyberg/yaml/";
          description = "Support for parsing and rendering YAML documents";
          license = stdenv.lib.licenses.bsd3;
        }) {};
      zlib = callPackage ({ base, bytestring, mkDerivation, stdenv, zlib }:
      mkDerivation {
          pname = "zlib";
          version = "0.6.1.2";
          sha256 = "e4eb4e636caf07a16a9730ce469a00b65d5748f259f43edd904dd457b198a2bb";
          libraryHaskellDepends = [
            base
            bytestring
          ];
          librarySystemDepends = [ zlib ];
          doHaddock = false;
          doCheck = false;
          description = "Compression and decompression in the gzip and zlib formats";
          license = stdenv.lib.licenses.bsd3;
        }) { zlib = pkgs.zlib; };
    };
in
compiler.override {
  initialPackages = stackPackages;
  configurationCommon = { ... }: self: super: {};
}
