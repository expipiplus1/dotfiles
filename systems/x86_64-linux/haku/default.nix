{ config, pkgs, lib, ... }:

{
  networking.hostName = "haku";
  imports = [ ./hardware ./impermanence.nix ];

  # Modules
  ellie.oci.enable = true;
  ellie.fail2ban.enable = true;
  ellie.users.enable = true;
  ellie.health = {
    enable = true;
    ntfyTopicFile = "/etc/secrets/ntfy_topic";
    ntfyTokenFile = "/etc/secrets/ntfy_token";
    diskCheck.paths = [ "/" ];
    loginNotify.ignoredCIDRs = [ "e@202.83.104.81/32" ];
  };

  # Networking
  networking.firewall.enable = true;
  time.timeZone = "Asia/Singapore";

  # SSH
  services.openssh = {
    enable = true;
    ports = [ 49813 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      MaxAuthTries = 2;
      LoginGraceTime = "30s";
    };
  };

  programs.mosh.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=256M
  '';

  # Nix
  nix.settings.auto-optimise-store = true;
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.extraOptions = ''
    min-free = ${toString (512 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';
  nix.settings.trusted-public-keys = [
    "orion:s0C06f1M46DCpHUUP2r8iIrhfytkCbXWltMeMMa4jbw="
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "light-hope:xkiDuhgkaC8uE9r3/Rr1R1QFozkqxP///eb+cdMFByA="
  ];

  zramSwap.enable = true;

  swapDevices = [{
    device = "/var/swapfile";
    size = 16 * 1024; # 16GB
  }];

  systemd.services.iosevka-builder = let
    ntfySend = pkgs.writeShellScript "iosevka-ntfy-send" ''
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
        -H "Title: [haku] $TITLE" \
        -H "Priority: $PRIORITY" \
        -H "Authorization: Bearer $TOKEN" \
        "''${TAG_ARGS[@]}" \
        -d "$MESSAGE" \
        "https://ntfy.sh/$TOPIC"
    '';
    ntfyOnStop = pkgs.writeShellScript "iosevka-ntfy-on-stop" ''
      # $SERVICE_RESULT and $EXIT_STATUS are set by systemd
      # ExecStopPost with ! runs as root; read secrets directly
      TOPIC=$(${pkgs.coreutils}/bin/tr -d '[:space:]' < /etc/secrets/ntfy_topic)
      TOKEN=$(${pkgs.coreutils}/bin/cat /etc/secrets/ntfy_token)
      PEAK=$(${pkgs.coreutils}/bin/cat /var/lib/iosevka-builder/mem-peak 2>/dev/null || echo "?")
      if [ "$SERVICE_RESULT" = "success" ]; then
        TITLE="Iosevka Build Complete"
        PRIO="default"
        TAGS="white_check_mark"
      else
        TITLE="Iosevka Builder Died"
        PRIO="urgent"
        TAGS="skull"
      fi
      ${pkgs.curl}/bin/curl -s \
        -H "Title: [haku] $TITLE" \
        -H "Priority: $PRIO" \
        -H "Tags: $TAGS" \
        -H "Authorization: Bearer $TOKEN" \
        -d "result=$SERVICE_RESULT status=$EXIT_STATUS peak=''${PEAK}MB" \
        "https://ntfy.sh/$TOPIC"
    '';
    overrides = builtins.concatStringsSep " " [
      "--override-input japan-transfer path:/home/e/dummy-flake"
      "--override-input kanji-explorer path:/home/e/dummy-flake"
      "--override-input anki-progress path:/home/e/dummy-flake"
      "--override-input ug-proxy path:/home/e/dummy-flake"
    ];
    stateDir = "/var/lib/iosevka-builder";
  in {
    description = "Build Iosevka fonts";
    after = [ "network-online.target" "multi-user.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [ nix git coreutils gawk procps ];
    environment = {
      HOME = "/home/e";
      NIX_PATH = "";
    };
    serviceConfig = {
      Type = "oneshot";
      User = "e";
      WorkingDirectory = "/home/e/dotfiles";
      Nice = 19;
      IOSchedulingClass = "idle";
      StateDirectory = "iosevka-builder";
      LoadCredential = [
        "ntfy_topic:/etc/secrets/ntfy_topic"
        "ntfy_token:/etc/secrets/ntfy_token"
      ];
      ExecStopPost = "!${ntfyOnStop}";
    };
    script = ''
      set -o pipefail
      PEAK_LOG="${stateDir}/peak-memory.log"

      # Update only nixpkgs (other inputs are overridden/unavailable)
      nix flake update nixpkgs 2>&1 || true

      for font in iosevka-term iosevka-aile iosevka-etoile; do
        ${ntfySend} "Iosevka Build" "Building $font..." "low" "hammer"

        # Reset peak tracking
        echo 0 > ${stateDir}/mem-peak

        # Start memory monitor in background
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

        if nix build ".#$font" ${overrides} --cores 1 -j 1 --no-link --print-out-paths -L 2>&1; then
          PEAK=$(cat ${stateDir}/mem-peak 2>/dev/null || echo "?")
          echo "$(date -Iseconds) $font OK peak=''${PEAK}MB" >> "$PEAK_LOG"
          ${ntfySend} "Iosevka Build" "$font built. Peak memory: ''${PEAK}MB" "default" "white_check_mark"
        else
          PEAK=$(cat ${stateDir}/mem-peak 2>/dev/null || echo "?")
          echo "$(date -Iseconds) $font FAIL peak=''${PEAK}MB" >> "$PEAK_LOG"
          ${ntfySend} "Iosevka Build" "$font FAILED. Peak: ''${PEAK}MB" "high" "x"
        fi

        kill $MONITOR_PID 2>/dev/null || true
        wait $MONITOR_PID 2>/dev/null || true
      done
    '';
  };

  systemd.timers.iosevka-builder = {
    description = "Periodically build Iosevka fonts";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnActiveSec = "1min";
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
  };

  system.stateVersion = "25.11";
}
