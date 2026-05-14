{ lib, pkgs, config, ... }@inputs:

with lib;
let
  cfg = config.ellie.health;

  # ── Shared ntfy send helper ─────────────────────────────────────────
  ntfySend = pkgs.writeShellScript "health-ntfy-send" ''
    # Usage: health-ntfy-send TITLE MESSAGE [PRIORITY] [TAGS]
    TITLE="$1"
    MESSAGE="$2"
    PRIORITY="''${3:-default}"
    TAGS="''${4:-}"

    TOPIC=$(${pkgs.coreutils}/bin/tr -d '[:space:]' < "${cfg.ntfyTopicFile}")
    if [ -z "$TOPIC" ]; then
      echo "health-ntfy-send: empty topic from ${cfg.ntfyTopicFile}" >&2
      exit 1
    fi

    AUTH_ARGS=()
    ${optionalString (cfg.ntfyTokenFile != null) ''
      if [ -f "${cfg.ntfyTokenFile}" ]; then
        AUTH_ARGS+=(-H "Authorization: Bearer $(cat "${cfg.ntfyTokenFile}")")
      fi
    ''}

    TAG_ARGS=()
    if [ -n "$TAGS" ]; then
      TAG_ARGS+=(-H "Tags: $TAGS")
    fi

    ${pkgs.curl}/bin/curl -s \
      -H "Title: [${cfg.hostname}] $TITLE" \
      -H "Priority: $PRIORITY" \
      "''${TAG_ARGS[@]}" \
      "''${AUTH_ARGS[@]}" \
      -d "$MESSAGE" \
      "${cfg.ntfyUrl}/$TOPIC"
  '';

  # ── Check scripts ───────────────────────────────────────────────────

  diskCheckScript = pkgs.writeShellScript "health-disk-check" ''
    STATE_DIR="/var/lib/health"
    BASE_COOLDOWN=3600        # 1 hour initial cooldown
    MAX_COOLDOWN=$((7*24*3600))  # cap at 7 days
    ${concatMapStringsSep "\n" (path: ''
      usage=$(${pkgs.coreutils}/bin/df --output=pcent ${
        escapeShellArg path
      } | ${pkgs.coreutils}/bin/tail -1 | ${pkgs.coreutils}/bin/tr -dc '0-9')
      STATE_PREFIX="$STATE_DIR/disk-$(echo ${
        escapeShellArg path
      } | ${pkgs.coreutils}/bin/tr '/' '_')"
      if [ "$usage" -ge ${toString cfg.diskCheck.threshold} ]; then
        COUNT=0
        if [ -f "''${STATE_PREFIX}-count" ]; then
          COUNT=$(${pkgs.coreutils}/bin/cat "''${STATE_PREFIX}-count")
        fi
        COOLDOWN=$((BASE_COOLDOWN * (1 << COUNT)))
        if [ "$COOLDOWN" -gt "$MAX_COOLDOWN" ]; then
          COOLDOWN=$MAX_COOLDOWN
        fi
        SEND=1
        if [ -f "''${STATE_PREFIX}-alerted" ]; then
          LAST=$(${pkgs.coreutils}/bin/cat "''${STATE_PREFIX}-alerted")
          NOW=$(${pkgs.coreutils}/bin/date +%s)
          if [ $((NOW - LAST)) -lt $COOLDOWN ]; then
            SEND=0
          fi
        fi
        if [ "$SEND" -eq 1 ]; then
          ${ntfySend} "Disk Alert" "${
            escapeShellArg path
          } is ''${usage}% full" "high" "warning"
          ${pkgs.coreutils}/bin/date +%s > "''${STATE_PREFIX}-alerted"
          echo $((COUNT + 1)) > "''${STATE_PREFIX}-count"
        fi
      else
        ${pkgs.coreutils}/bin/rm -f "''${STATE_PREFIX}-alerted" "''${STATE_PREFIX}-count"
      fi
    '') cfg.diskCheck.paths}
  '';

  btrfsCheckScript = pkgs.writeShellScript "health-btrfs-check" ''
    ${concatMapStringsSep "\n" (dev: ''
            output=$(${pkgs.btrfs-progs}/bin/btrfs device stats ${
              escapeShellArg dev
            } 2>&1)
            errors=$(echo "$output" | ${pkgs.gawk}/bin/awk '{sum += $NF} END {print sum+0}')
            if [ "$errors" -gt 0 ]; then
              ${ntfySend} "Btrfs Errors" "Device errors on ${
                escapeShellArg dev
              }:
      $output" "urgent" "rotating_light"
            fi
    '') cfg.btrfsCheck.devices}
  '';

  memoryCheckScript = pkgs.writeShellScript "health-memory-check" ''
    STATE_DIR="/var/lib/health"
    BASE_COOLDOWN=3600           # 1 hour initial cooldown
    MAX_COOLDOWN=$((24*3600))    # cap at 24 hours
    eval $(${pkgs.gawk}/bin/awk '
      /^MemTotal:/     {mt=$2}
      /^MemAvailable:/ {ma=$2}
      /^SwapTotal:/    {st=$2}
      /^SwapFree:/     {sf=$2}
      END {
        total = mt + st
        used  = (mt - ma) + (st - sf)
        printf "total_kb=%d used_kb=%d\n", total, used
      }
    ' /proc/meminfo)
    if [ "$total_kb" -eq 0 ]; then exit 0; fi
    pct=$(( used_kb * 100 / total_kb ))
    if [ "$pct" -ge ${toString cfg.memoryCheck.threshold} ]; then
      COUNT=0
      if [ -f "$STATE_DIR/memory-count" ]; then
        COUNT=$(${pkgs.coreutils}/bin/cat "$STATE_DIR/memory-count")
      fi
      COOLDOWN=$((BASE_COOLDOWN * (1 << COUNT)))
      if [ "$COOLDOWN" -gt "$MAX_COOLDOWN" ]; then
        COOLDOWN=$MAX_COOLDOWN
      fi
      SEND=1
      if [ -f "$STATE_DIR/memory-alerted" ]; then
        LAST=$(${pkgs.coreutils}/bin/cat "$STATE_DIR/memory-alerted")
        NOW=$(${pkgs.coreutils}/bin/date +%s)
        if [ $((NOW - LAST)) -lt $COOLDOWN ]; then
          SEND=0
        fi
      fi
      if [ "$SEND" -eq 1 ]; then
        used_mb=$(( used_kb / 1024 ))
        total_mb=$(( total_kb / 1024 ))
        ${ntfySend} "Memory Alert" "Memory+swap ''${pct}% used (''${used_mb}MB / ''${total_mb}MB)" "high" "warning"
        ${pkgs.coreutils}/bin/date +%s > "$STATE_DIR/memory-alerted"
        echo $((COUNT + 1)) > "$STATE_DIR/memory-count"
      fi
    else
      ${pkgs.coreutils}/bin/rm -f "$STATE_DIR/memory-alerted" "$STATE_DIR/memory-count"
    fi
  '';

  loginNotifyScript = let
    ignoreRules = cfg.loginNotify.ignoredCIDRs;
    # Generate a Python snippet that checks user@CIDR rules
    pyCheck = pkgs.writeScript "health-login-check" ''
      #!${pkgs.python3}/bin/python3
      import ipaddress, sys, os
      user = os.environ.get("PAM_USER", "")
      rhost = os.environ.get("PAM_RHOST", "")
      if not rhost:
          sys.exit(0)
      try:
          addr = ipaddress.ip_address(rhost)
      except ValueError:
          sys.exit(1)
      rules = ${builtins.toJSON ignoreRules}
      for rule in rules:
          if "@" in rule:
              ru, cidr = rule.rsplit("@", 1)
              if user == ru and addr in ipaddress.ip_network(cidr, strict=False):
                  sys.exit(0)
          else:
              if addr in ipaddress.ip_network(rule, strict=False):
                  sys.exit(0)
      sys.exit(1)
    '';
  in pkgs.writeShellScript "health-login-notify" ''
    if [ "$PAM_TYPE" = "open_session" ]; then
      if ! ${pyCheck}; then
        ${ntfySend} "SSH Login" "User $PAM_USER from $PAM_RHOST" "default" "key"
      fi
    fi
  '';

  rebootNotifyScript = pkgs.writeShellScript "health-reboot-notify" ''
    kernel=$(${pkgs.coreutils}/bin/uname -r)
    uptime_s=$(${pkgs.gawk}/bin/awk '{print int($1)}' /proc/uptime)
    boot_time=$(${pkgs.coreutils}/bin/date -d "-''${uptime_s} seconds" '+%Y-%m-%d %H:%M:%S')
    ${ntfySend} "System Booted" "Booted at $boot_time, kernel $kernel" "default" "arrows_counterclockwise"
  '';

  monthlyReportScript = pkgs.writeShellScript "health-monthly-report" ''
    R=""

    # Uptime
    R="$R$(${pkgs.procps}/bin/uptime -p)"$'\n'

    # Disk usage
    ${concatMapStringsSep "\n" (path: ''
      usage=$(${pkgs.coreutils}/bin/df -h ${
        escapeShellArg path
      } | ${pkgs.coreutils}/bin/tail -1 | ${pkgs.gawk}/bin/awk '{print $3 "/" $2 " (" $5 ")"}')
      R="''${R}Disk ${escapeShellArg path}: $usage"$'\n'
    '') cfg.diskCheck.paths}

    # Memory
    mem=$(${pkgs.procps}/bin/free -h | ${pkgs.gawk}/bin/awk '/^Mem:/ {print $3 "/" $2}')
    R="''${R}Memory: $mem"$'\n'

    # Swap
    swap=$(${pkgs.procps}/bin/free -h | ${pkgs.gawk}/bin/awk '/^Swap:/ {print $3 "/" $2}')
    R="''${R}Swap: $swap"$'\n'

    # Load
    load=$(${pkgs.coreutils}/bin/cat /proc/loadavg | ${pkgs.gawk}/bin/awk '{print $1, $2, $3}')
    R="''${R}Load: $load"$'\n'

    ${optionalString cfg.btrfsCheck.enable ''
      # Btrfs
      ${concatMapStringsSep "\n" (dev: ''
        output=$(${pkgs.btrfs-progs}/bin/btrfs device stats ${
          escapeShellArg dev
        } 2>&1)
        errors=$(echo "$output" | ${pkgs.gawk}/bin/awk '{sum += $NF} END {print sum+0}')
        if [ "$errors" -eq 0 ]; then
          R="''${R}Btrfs ${escapeShellArg dev}: OK"$'\n'
        else
          R="''${R}Btrfs ${escapeShellArg dev}: ERRORS ($errors)"$'\n'
        fi
      '') cfg.btrfsCheck.devices}
    ''}

    # Failed units
    failed=$(${pkgs.systemd}/bin/systemctl --failed --no-legend | ${pkgs.coreutils}/bin/wc -l)
    R="''${R}Failed units: $failed"$'\n'
    if [ "$failed" -gt 0 ]; then
      list=$(${pkgs.systemd}/bin/systemctl --failed --no-legend | ${pkgs.gawk}/bin/awk '{print "  " $2}' | ${pkgs.coreutils}/bin/head -5)
      R="''${R}$list"$'\n'
    fi

    # NixOS generation
    gen=$(${pkgs.coreutils}/bin/readlink /nix/var/nix/profiles/system | ${pkgs.gnused}/bin/sed 's/.*-//')
    R="''${R}NixOS generation: $gen"

    ${ntfySend} "Monthly Report" "$R" "low" "bar_chart"
  '';

  deadmanCheckScript = pkgs.writeShellScript "health-deadman-check" ''
    STATE_DIR="/var/lib/health"
    FAIL_FILE="$STATE_DIR/deadman-fail-count"
    ALERTED_FILE="$STATE_DIR/deadman-alerted"

    PEER_ALIVE=0
    HTTP_CODE=$(${pkgs.curl}/bin/curl -so /dev/null --max-time 10 -w '%{http_code}' ${
      escapeShellArg cfg.deadManSwitch.peerUrl
    } 2>/dev/null || true)
    if [ -n "$HTTP_CODE" ] && [ "$HTTP_CODE" -gt 0 ] 2>/dev/null; then
      PEER_ALIVE=1
    fi

    if [ "$PEER_ALIVE" -eq 1 ]; then
      if [ -f "$ALERTED_FILE" ]; then
        ${ntfySend} "Peer Recovered" "${cfg.deadManSwitch.peerName} is back online" "default" "white_check_mark"
        rm -f "$ALERTED_FILE"
      fi
      echo 0 > "$FAIL_FILE"
    else
      CURRENT=$(${pkgs.coreutils}/bin/cat "$FAIL_FILE" 2>/dev/null || echo 0)
      CURRENT=$((CURRENT + 1))
      echo "$CURRENT" > "$FAIL_FILE"

      if [ "$CURRENT" -ge ${
        toString cfg.deadManSwitch.failCount
      } ] && [ ! -f "$ALERTED_FILE" ]; then
        ${ntfySend} "Peer DOWN" "${cfg.deadManSwitch.peerName} unreachable for $CURRENT consecutive checks" "urgent" "rotating_light,skull"
        touch "$ALERTED_FILE"
      fi
    fi
  '';

  # ── Helper: timer+service pair ────────────────────────────────────
  mkHealthService = name: script: {
    description = "Health check: ${name}";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = script;
      StateDirectory = "health";
    };
  };

  mkHealthTimer = interval: {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = interval;
      Persistent = true;
    };
  };

in {
  options.ellie.health = {
    enable = mkEnableOption "system health monitoring with ntfy notifications";

    ntfyUrl = mkOption {
      type = types.str;
      default = "https://ntfy.sh";
      description = "Base URL of the ntfy server.";
    };

    ntfyTopicFile = mkOption {
      type = types.str;
      description =
        "Path to file containing the ntfy topic name (one line, no newline).";
    };

    ntfyTokenFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to file containing an ntfy bearer token.";
    };

    hostname = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "Human-readable hostname for notification titles.";
    };

    diskCheck = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Check disk space usage.";
      };
      paths = mkOption {
        type = types.listOf types.str;
        default = [ "/" ];
        description = "Mount points to monitor.";
      };
      threshold = mkOption {
        type = types.int;
        default = 97;
        description = "Usage percentage at which to alert.";
      };
      interval = mkOption {
        type = types.str;
        default = "*:0/15";
        description = "systemd OnCalendar expression.";
      };
    };

    btrfsCheck = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Check btrfs device stats for errors.";
      };
      devices = mkOption {
        type = types.listOf types.str;
        default = [ "/" ];
        description = "Btrfs mount points to check.";
      };
      interval = mkOption {
        type = types.str;
        default = "hourly";
        description = "systemd OnCalendar expression.";
      };
    };

    memoryCheck = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Check memory usage.";
      };
      threshold = mkOption {
        type = types.int;
        default = 90;
        description = "Usage percentage at which to alert.";
      };
      interval = mkOption {
        type = types.str;
        default = "*:0/15";
        description = "systemd OnCalendar expression.";
      };
    };

    loginNotify = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Notify on SSH login.";
      };
      ignoredCIDRs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          List of "user@CIDR" patterns to suppress login notifications for.
          e.g. [ "e@192.168.1.0/24" ] to ignore user e from the LAN.
          Use just a CIDR (no @) to ignore all users from that range.
        '';
      };
    };

    rebootNotify = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Notify on system boot.";
      };
    };

    monthlyReport = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Send a monthly health summary.";
      };
      calendar = mkOption {
        type = types.str;
        default = "*-*-01 08:00:00";
        description =
          "systemd OnCalendar expression (default: 1st of month, 8am).";
      };
    };

    healthEndpoint = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        If set, create an nginx vhost at this hostname that returns 200 OK
        with no authentication. Used as the dead-man's switch target by
        the peer host.
      '';
    };

    deadManSwitch = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Monitor a peer host and alert if it goes down.";
      };
      peerName = mkOption {
        type = types.str;
        default = "";
        description = "Human-readable name of the peer.";
      };
      peerUrl = mkOption {
        type = types.str;
        default = "";
        description = "HTTPS URL to check for peer liveness.";
      };
      interval = mkOption {
        type = types.str;
        default = "*:0/5";
        description = "systemd OnCalendar expression.";
      };
      failCount = mkOption {
        type = types.int;
        default = 3;
        description = "Consecutive failures before alerting.";
      };
    };
  };

  config = mkIf cfg.enable {
    # ── Systemd services ──────────────────────────────────────────────
    systemd.services = (optionalAttrs cfg.diskCheck.enable {
      health-disk-check = mkHealthService "disk-check" diskCheckScript;
    }) // (optionalAttrs cfg.btrfsCheck.enable {
      health-btrfs-check = mkHealthService "btrfs-check" btrfsCheckScript;
    }) // (optionalAttrs cfg.memoryCheck.enable {
      health-memory-check = mkHealthService "memory-check" memoryCheckScript;
    }) // (optionalAttrs cfg.deadManSwitch.enable {
      health-deadman-check = mkHealthService "deadman-check" deadmanCheckScript;
    }) // (optionalAttrs cfg.monthlyReport.enable {
      health-monthly-report =
        mkHealthService "monthly-report" monthlyReportScript;
    }) // (optionalAttrs cfg.rebootNotify.enable {
      health-reboot-notify = {
        description = "Notify on system boot";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = rebootNotifyScript;
        };
      };
    });

    # ── Systemd timers ────────────────────────────────────────────────
    systemd.timers = (optionalAttrs cfg.diskCheck.enable {
      health-disk-check = mkHealthTimer cfg.diskCheck.interval;
    }) // (optionalAttrs cfg.btrfsCheck.enable {
      health-btrfs-check = mkHealthTimer cfg.btrfsCheck.interval;
    }) // (optionalAttrs cfg.memoryCheck.enable {
      health-memory-check = mkHealthTimer cfg.memoryCheck.interval;
    }) // (optionalAttrs cfg.deadManSwitch.enable {
      health-deadman-check = mkHealthTimer cfg.deadManSwitch.interval;
    }) // (optionalAttrs cfg.monthlyReport.enable {
      health-monthly-report = mkHealthTimer cfg.monthlyReport.calendar;
    });

    # ── PAM login notification ────────────────────────────────────────
    security.pam.services.sshd = mkIf cfg.loginNotify.enable {
      rules.session.health-login-notify = {
        order = 99999;
        control = "optional";
        modulePath = "pam_exec.so";
        args = [ (toString loginNotifyScript) ];
      };
    };

    # ── Health endpoint for dead-man's switch ─────────────────────────
    services.nginx.virtualHosts = mkIf (cfg.healthEndpoint != null) {
      ${cfg.healthEndpoint} = {
        forceSSL = true;
        useACMEHost = "monoid.al";
        locations."/" = {
          return = "200 'ok'";
          extraConfig = ''
            default_type text/plain;
          '';
        };
      };
    };
  };
}
