{ lib, ... }:

{
  boot.kernelPatches = [{
    name = "disable-af_alg";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      CRYPTO_USER_API = option no;
    };
  }];
}
