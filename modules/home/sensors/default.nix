{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "sensors" {
  home.packages = with pkgs;
    [
      (pkgs.writeShellApplication {
        name = "temps";
        runtimeInputs = [ lm_sensors ];
        text = ''
          temps=$(sensors --config-file ${
            ./sensors.conf
          } --no-adapter 'k10temp-*' 'asusec-*' 'nct6799-*' "$@")
          ccd1=$(cat /sys/devices/system/cpu/cpu{0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23}/cpufreq/scaling_cur_freq | nl | sort -n -k 2)
          ccd2=$(cat /sys/devices/system/cpu/cpu{8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31}/cpufreq/scaling_cur_freq | nl | sort -n -k 2)
          paste <(cat <<< "$ccd1") <(cat <<< "$ccd2") <(cat <<< "$temps") | column -s $'\t' -tne
        '';
      })
    ];
}
