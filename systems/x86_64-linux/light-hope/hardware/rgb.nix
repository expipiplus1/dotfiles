{ config, lib, pkgs, modulesPath, ... }:

{
  services.hardware.lian-li-pump-control = {
    enable = true;
    speed = "pwm";
    color = "sync";
  };

  services.hardware.lian-li-fan-control = {
    enable = true;
    speed = "pwm";
    color = "nosync";
  };

  services.udev.packages = [ pkgs.openrgb ];
  systemd.services.openrgb-oneshot = {
    description = "OpenRGB oneshot";
    wantedBy = [
      "multi-user.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    wants = [ "lian-li-fan-control.service" "lian-li-pump-control.service" ];
    after = [
      "lian-li-fan-control.service"
      "lian-li-pump-control.service"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    serviceConfig = {
      StateDirectory = "OpenRGB";
      WorkingDirectory = "/var/lib/OpenRGB";
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.openrgb}/bin/openrgb --noautoconnect"
        "--device X670E --zone 0 --brightness 100 --size 3 --color a30054,e74224,c01116"
        "--device X670E --zone 1 --brightness 100 --size 8 --color a30054,be0127,da1e09,ee5431,f6744c,ce2a24,a90009,a20036"
        "--device X670E --zone 2 --brightness 100 --size 8 --color a30054,be0027,da0009,ee0031,f6004c,ce0024,a90009,a20036"
        "--device 'Uni Hub' --zone 1 --brightness 100 --size 20 --color a30054,ae0041,b9002e,c5061c,d00e09,da1e09,e2351a,eb4b2b,f3623c,fb794d,f6744c,e5553b,d4362a,c31719,b20008,a90009,a6001c,a3002e,a10041,9e0054"
        "--device 'Uni Hub' --zone 2 --brightness 100 --size 16 --color a30054,b0003d,be0127,cc0b11,da1e09,e4391d,ee5431,f87046,f6744c,e24f38,ce2a24,b9050f,a90009,a60020,a20036,9f004c"
        "--device 'Uni Hub' --zone 3 --brightness 100 --size 48 --color a30054,a7004c,ac0045,b0003d,b50036,b9002e,be0127,c30420,c70718,cc0b11,d20f06,d71502,da1e09,de2710,e13016,e4391d,e74224,eb4b2b,ee5431,f15e38,f4673f,f87046,fd7d50,fd8053,f6744c,ef6845,e95b3f,e24f38,db4331,d4362a,ce2a24,c71e1d,c01116,b9050f,af0005,aa0002,a90009,a80011,a70018,a60020,a50027,a3002e,a20036,a1003d,a00045,9f004c,9e0058,9e005b"
      ];
      Type = "oneshot";
    };
  };
}
