{ config, lib, pkgs, ... }:

let
  envFile = "/etc/secrets/historian-bow-matrix-token";
  room = "!ycoJWcnXwYGClWSegW:monoid.al";
  server = "matrix.monoid.al";

  sendMessage = pkgs.writeShellScript "sendMessage" ''
    message=$1
    format() {
      ${pkgs.pandoc}/bin/pandoc --from markdown --to $1 | ${pkgs.jq}/bin/jq -Rs .
    }
    ${pkgs.curl}/bin/curl -XPOST -d '
      { "msgtype":"m.text"
      , "format": "org.matrix.custom.html"
      , "body": '"$(format plain < $message )"'
      , "formatted_body":'"$(format html < $message)"'
      }' \
      "https://$server/_matrix/client/r0/rooms/$room/send/m.room.message?access_token=$ACCESS_TOKEN"
  '';

  hysterical = pkgs.writeShellScript "hysterical" ''
    ts=$1
    interval=$2
    message=$3
    if [ -f "$message" ]; then
      if [ -f "$ts" ]; then
        time_run=$(cat "$ts")
        current_time=$(date +"%s")
        if [ "$current_time" -lt "$time_run" ]; then
          echo "not messaging again until $time_run"
          exit
        fi
      fi

      ${sendMessage} "$message"
      date -d "+$interval" +"%s" > $ts
    else
      rm -f "$ts"
    fi
  '';

  oneshotConfig = {
    DynamicUser = true;
    Type = "oneshot";
    EnvironmentFile = envFile;
    PrivateTmp = true;
  };

  systemdEscape = builtins.replaceStrings [ "/" ] [ "-" ];
  filesystems = map systemdEscape [ "/" "/data" ];

  machines = map systemdEscape [ "gamora" "monoid.al" ];

in lib.mkMerge [
  {
    systemd.timers.report = {
      wantedBy = [ "timers.target" ];
      partOf = [ "report.service" ];
      timerConfig.OnCalendar = "weekly";
    };
    systemd.services.report = {
      after = [ "network.target" ];
      serviceConfig = oneshotConfig;
      environment = { inherit room server; };
      script = ''
        message=/tmp/message.md
        echo '```' >> $message
        echo "Disk free: $(df -h)." >> $message
        echo '```' >> $message
        ${sendMessage} "$message"
        echo $?
      '';
    };
  }
  {
    systemd.timers = lib.listToAttrs (map (machine: {
      name = "machine-check@${machine}";
      value = {
        wantedBy = [ "timers.target" ];
        partOf = [ "machine-check@.service" ];
        timerConfig.OnCalendar = "hourly";
      };
    }) machines);

    systemd.services."machine-check@" = {
      after = [ "network.target" ];
      serviceConfig = oneshotConfig // {
        StateDirectory = "machine-check";
        DynamicUser = false;
        ExecStart = let
          checkmachine = pkgs.writeShellScript "checkmachine" ''
                        machine=$1
                        machineEscaped=$2
                        interval="1 day"
                        message=/tmp/message.md
                        ts=$STATE_DIRECTORY/$machineEscaped

                        if ! ping -c1 "$machine"; then
                          echo '`'$machine'` is unreachable' >> $message
            	    elif [ -f "$ts" ]; then
            	      echo "$machine up again" >> /tmp/up_again
            	      ${sendMessage} /tmp/up_again
                        fi

                        ${hysterical} "$ts" "$interval" "$message"
          '';
        in "${checkmachine} %I %i";
      };
      environment = { inherit room server; };
      path = with pkgs; [ iputils ];
    };
  }
  {
    systemd.timers = lib.listToAttrs (map (fs: {
      name = "fs-check@${fs}";
      value = {
        wantedBy = [ "timers.target" ];
        partOf = [ "fs-check@.service" ];
        timerConfig.OnCalendar = "hourly";
      };
    }) filesystems);

    systemd.services."fs-check@" = {
      after = [ "network.target" ];
      serviceConfig = oneshotConfig // {
        StateDirectory = "fs-check";
        DynamicUser = false;
        ExecStart = let
          checkFS = pkgs.writeShellScript "checkfs" ''
            fs=$1
            fsEscaped=$2
            interval="1 day"
            message=/tmp/message.md
            ts=$STATE_DIRECTORY/$fsEscaped

            ret=0
            btrfs device stats --check "$fs" > /tmp/report || ret=$?

            if [ "$ret" -ne 0 ]; then
              echo '`'$fs'` has errors:' >> $message
              echo '```' >> $message
              cat /tmp/report >> $message
              echo '```' >> $message
            fi

            ${hysterical} "$ts" "$interval" "$message"
          '';
        in "${checkFS} %I %i";
      };
      environment = { inherit room server; };
      path = with pkgs; [ btrfs-progs ];
    };
  }
]
