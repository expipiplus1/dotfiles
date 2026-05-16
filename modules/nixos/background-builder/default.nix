{ lib, pkgs, config, ... }@inputs:

with lib;
let
  cfg = config.ellie.background-builder;
  hasNtfy = cfg.ntfyTopicFile != null && cfg.ntfyTokenFile != null;

  # ntfySend is a no-op when credentials aren't available at runtime
  ntfySend = pkgs.writeShellScript "background-builder-ntfy-send" ''
    if [ -z "''${CREDENTIALS_DIRECTORY:-}" ] \
       || [ ! -f "$CREDENTIALS_DIRECTORY/ntfy_topic" ] \
       || [ ! -f "$CREDENTIALS_DIRECTORY/ntfy_token" ]; then
      exit 0
    fi

    TITLE="$1"
    MESSAGE="$2"
    PRIORITY="''${3:-default}"
    TAGS="''${4:-}"

    TOPIC=$(${pkgs.coreutils}/bin/tr -d '[:space:]' < "$CREDENTIALS_DIRECTORY/ntfy_topic")
    TOKEN=$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/ntfy_token")

    TAG_ARGS=()
    if [ -n "$TAGS" ]; then
      TAG_ARGS+=(-H "Tags: $TAGS")
    fi

    ${pkgs.curl}/bin/curl -s \
      -H "Title: [${cfg.hostname}] $TITLE" \
      -H "Priority: $PRIORITY" \
      -H "Authorization: Bearer $TOKEN" \
      "''${TAG_ARGS[@]}" \
      -d "$MESSAGE" \
      "https://ntfy.sh/$TOPIC" || true
  '';

  ntfyOnStop = pkgs.writeShellScript "background-builder-ntfy-on-stop" ''
    ${if hasNtfy then ''
      if [ ! -f ${escapeShellArg cfg.ntfyTopicFile} ] \
         || [ ! -f ${escapeShellArg cfg.ntfyTokenFile} ]; then
        exit 0
      fi

      TOPIC=$(${pkgs.coreutils}/bin/tr -d '[:space:]' < ${escapeShellArg cfg.ntfyTopicFile})
      TOKEN=$(${pkgs.coreutils}/bin/cat ${escapeShellArg cfg.ntfyTokenFile})
    '' else ''
      exit 0
    ''}
    PEAK=$(${pkgs.coreutils}/bin/cat ${stateDir}/mem-peak 2>/dev/null || echo "?")
    START=$(${pkgs.coreutils}/bin/cat ${stateDir}/start-time 2>/dev/null || echo "")
    if [ -n "$START" ]; then
      ELAPSED=$(( $(${pkgs.coreutils}/bin/date +%s) - START ))
      HOURS=$(( ELAPSED / 3600 ))
      MINS=$(( (ELAPSED % 3600) / 60 ))
      TIME_STR="''${HOURS}h''${MINS}m"
    else
      TIME_STR="?"
    fi
    if [ "$SERVICE_RESULT" = "success" ]; then
      TITLE="Build Complete"
      PRIO="default"
      TAGS="white_check_mark"
    else
      TITLE="Builder Died"
      PRIO="urgent"
      TAGS="skull"
    fi
    ${pkgs.curl}/bin/curl -s \
      -H "Title: [${cfg.hostname}] $TITLE" \
      -H "Priority: $PRIO" \
      -H "Tags: $TAGS" \
      -H "Authorization: Bearer $TOKEN" \
      -d "result=$SERVICE_RESULT status=$EXIT_STATUS time=$TIME_STR peak=''${PEAK}MB" \
      "https://ntfy.sh/$TOPIC" || true
  '';

  dummyFlakeDir = "${stateDir}/dummy-flake";

  overrides = builtins.concatStringsSep " " (map
    (name: "--override-input ${name} path:${dummyFlakeDir}")
    cfg.overrideInputs
  );

  stateDir = "/var/lib/background-builder";

  # Derive a short name from the last dotted segment of the flake attr
  shortName = p: lib.last (lib.splitString "." p.flakeAttr);

in {
  options.ellie.background-builder = {
    enable = mkEnableOption "background nix package builder";

    hostname = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "Hostname used in notification titles.";
    };

    packages = mkOption {
      type = types.listOf (types.coercedTo types.str (flakeAttr: { inherit flakeAttr; }) (types.submodule {
        options = {
          flakeAttr = mkOption {
            type = types.str;
            description = "Flake attribute to build (e.g. nixosConfigurations.light-hope.config.ellie.fonts.iosevka-term).";
          };
          cores = mkOption {
            type = types.int;
            default = 1;
            description = "Number of cores to use for this build.";
          };
          jobs = mkOption {
            type = types.int;
            default = 1;
            description = "Number of parallel jobs for this build.";
          };
        };
      }));
      default = [];
      description = "List of packages to build in the background. Can be flake attr strings or attrsets with flakeAttr/cores/jobs.";
    };

    flakeDir = mkOption {
      type = types.str;
      default = "${stateDir}/repo";
      description = "Path to the local flake checkout.";
    };

    flakeURL = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "HTTPS URL to clone/pull the flake repo from (e.g. https://github.com/user/dotfiles). If set, the repo is cloned on first run and pulled on subsequent runs.";
    };

    user = mkOption {
      type = types.str;
      default = "e";
      description = "User to run the builder as.";
    };

    overrideInputs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Flake inputs to override with a dummy flake (for inputs unavailable on the build host).";
    };

    ntfyTopicFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to file containing the ntfy topic. Notifications are disabled if null.";
    };

    ntfyTokenFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to file containing the ntfy bearer token. Notifications are disabled if null.";
    };

    timerConfig = mkOption {
      type = types.attrs;
      default = {
        OnActiveSec = "1min";
        OnUnitActiveSec = "1h";
        Persistent = true;
      };
      description = "Systemd timer configuration.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.background-builder = {
      description = "Build packages in the background";
      after = [ "network-online.target" "multi-user.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [ nix git coreutils gawk procps ];
      environment = {
        HOME = stateDir;
        NIX_PATH = "";
      };
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Nice = 19;
        IOSchedulingClass = "idle";
        StateDirectory = "background-builder";
        ExecStopPost = "!${ntfyOnStop}";
      } // optionalAttrs hasNtfy {
        LoadCredential = [
          "ntfy_topic:${cfg.ntfyTopicFile}"
          "ntfy_token:${cfg.ntfyTokenFile}"
        ];
      };
      script = ''
        set -o pipefail
        PEAK_LOG="${stateDir}/peak-memory.log"

        date +%s > ${stateDir}/start-time

        # Create dummy flake for overriding unavailable inputs
        mkdir -p ${dummyFlakeDir}
        cat > ${dummyFlakeDir}/flake.nix << 'DUMMY'
        { outputs = { self, ... }: { }; }
        DUMMY

        ${optionalString (cfg.flakeURL != null) ''
          # Clone or update the flake repo
          if [ ! -d ${escapeShellArg cfg.flakeDir}/.git ]; then
            echo "Cloning ${cfg.flakeURL} to ${cfg.flakeDir}..."
            if ! git clone ${escapeShellArg cfg.flakeURL} ${escapeShellArg cfg.flakeDir}; then
              ${ntfySend} "Repo" "git clone failed" "high" "x"
              exit 1
            fi
          else
            echo "Pulling latest changes..."
            if ! git -C ${escapeShellArg cfg.flakeDir} pull --ff-only; then
              ${ntfySend} "Repo" "git pull --ff-only failed" "high" "warning"
            fi
          fi
        ''}

        cd ${escapeShellArg cfg.flakeDir}

        # Update all fetchable inputs (overridden ones use the dummy flake)
        if ! nix flake update ${overrides} 2>&1; then
          ${ntfySend} "Update" "nix flake update failed" "high" "warning"
        fi

        ${concatMapStrings (p: let
          pkg = shortName p;
        in ''
          PKG_START=$(date +%s)
          ${ntfySend} "Build" "Building ${pkg}..." "low" "hammer"

          echo 0 > ${stateDir}/mem-peak

          # Memory monitor
          (
            while true; do
              MEM=$(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print int((t-a)/1024)}' /proc/meminfo)
              SWAP=$(awk '/^SwapTotal:/{t=$2} /^SwapFree:/{f=$2} END{print int((t-f)/1024)}' /proc/meminfo)
              TOTAL=$((MEM + SWAP))
              PREV=$(cat ${stateDir}/mem-peak 2>/dev/null || echo 0)
              if [ "$TOTAL" -gt "$PREV" ]; then
                echo "$TOTAL" > ${stateDir}/mem-peak
              fi
              sleep 5
            done
          ) &
          MONITOR_PID=$!

          if OUT_PATH=$(nix build ${escapeShellArg ".#${p.flakeAttr}"} ${overrides} --cores ${toString p.cores} -j ${toString p.jobs} --no-link --print-out-paths -L); then
            PEAK=$(cat ${stateDir}/mem-peak 2>/dev/null || echo "?")
            PKG_ELAPSED=$(( $(date +%s) - PKG_START ))
            PKG_H=$(( PKG_ELAPSED / 3600 ))
            PKG_M=$(( (PKG_ELAPSED % 3600) / 60 ))
            echo "$(date -Iseconds) ${pkg} OK ''${PKG_H}h''${PKG_M}m peak=''${PEAK}MB" >> "$PEAK_LOG"

            # Keep a GC root and record the output path for consumers
            if [ -n "$OUT_PATH" ]; then
              mkdir -p ${stateDir}/roots ${stateDir}/latest-paths
              nix-store --realise $OUT_PATH --add-root "${stateDir}/roots/${pkg}" --indirect
              echo "$OUT_PATH" > "${stateDir}/latest-paths/${pkg}"
            fi

            ${ntfySend} "Build" "${pkg} built in ''${PKG_H}h''${PKG_M}m. Peak memory: ''${PEAK}MB" "default" "white_check_mark"
          else
            PEAK=$(cat ${stateDir}/mem-peak 2>/dev/null || echo "?")
            PKG_ELAPSED=$(( $(date +%s) - PKG_START ))
            PKG_H=$(( PKG_ELAPSED / 3600 ))
            PKG_M=$(( (PKG_ELAPSED % 3600) / 60 ))
            echo "$(date -Iseconds) ${pkg} FAIL ''${PKG_H}h''${PKG_M}m peak=''${PEAK}MB" >> "$PEAK_LOG"
            ${ntfySend} "Build" "${pkg} FAILED after ''${PKG_H}h''${PKG_M}m. Peak: ''${PEAK}MB" "high" "x"
          fi

          kill $MONITOR_PID 2>/dev/null || true
          wait $MONITOR_PID 2>/dev/null || true
        '') cfg.packages}
      '';
    };

    systemd.timers.background-builder = {
      description = "Periodically build packages in the background";
      wantedBy = [ "timers.target" ];
      timerConfig = cfg.timerConfig;
    };
  };
}
