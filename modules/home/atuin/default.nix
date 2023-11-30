{ lib, ... }@inputs:
lib.internal.simpleModule inputs "atuin" {
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      update_check = false;
      search_mode = "fuzzy";
    };
  };

}
