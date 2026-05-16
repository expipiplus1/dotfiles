{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.ellie.store-sync;
  stateDir = "/var/lib/store-sync";

  sshOpts = concatStringsSep " " [
    "-i ${escapeShellArg cfg.sshKeyFile}"
    "-p ${toString cfg.remotePort}"
    "-o ConnectTimeout=10"
    "-o StrictHostKeyChecking=accept-new"
    "-o BatchMode=yes"
  ];

  storeURI = "ssh://${cfg.remoteSSH}:${toString cfg.remotePort}?ssh-key=${cfg.sshKeyFile}";

in {
  options.ellie.store-sync = {
    enable = mkEnableOption "periodic syncing of pre-built store paths from a remote builder";

    remoteSSH = mkOption {
      type = types.str;
      description = "SSH user@host for the remote builder (e.g. e@haku).";
    };

    remotePort = mkOption {
      type = types.int;
      default = 22;
      description = "SSH port for the remote builder.";
    };

    sshKeyFile = mkOption {
      type = types.str;
      description = "Path to SSH private key for connecting to the builder.";
    };

    remoteStateDir = mkOption {
      type = types.str;
      default = "/var/lib/background-builder";
      description = "StateDirectory on the remote where build manifests are stored.";
    };

    packages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Package names to pull (must match background-builder package names).";
    };

    user = mkOption {
      type = types.str;
      default = "e";
      description = "User to run the service as (must have SSH key access).";
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
    systemd.services.store-sync = {
      description = "Pull pre-built packages from remote builder";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [ nix openssh coreutils ];
      environment = {
        HOME = "/home/${cfg.user}";
        NIX_PATH = "";
      };
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Nice = 19;
        IOSchedulingClass = "idle";
        StateDirectory = "store-sync";
      };
      script = ''
        set -euo pipefail

        mkdir -p ${stateDir}/roots

        for pkg in ${escapeShellArgs cfg.packages}; do
          echo "[$pkg] checking remote manifest..."

          # Read the store path the builder recorded
          REMOTE_PATH=$(ssh ${sshOpts} ${escapeShellArg cfg.remoteSSH} \
            "cat ${escapeShellArg cfg.remoteStateDir}/latest-paths/$pkg" 2>/dev/null) || {
            echo "[$pkg] WARNING: could not read manifest from remote (unreachable or not built yet)"
            continue
          }

          if [ -z "$REMOTE_PATH" ]; then
            echo "[$pkg] WARNING: empty manifest, skipping"
            continue
          fi

          # Check if already present locally
          if [ -e "$REMOTE_PATH" ]; then
            echo "[$pkg] $REMOTE_PATH already in local store"
          else
            echo "[$pkg] pulling $REMOTE_PATH..."
            nix copy --from ${escapeShellArg storeURI} "$REMOTE_PATH" || {
              echo "[$pkg] WARNING: failed to copy from remote"
              continue
            }
          fi

          # Create/update GC root (replaces previous version automatically)
          nix-store --add-root "${stateDir}/roots/$pkg" --indirect --realise "$REMOTE_PATH"

          echo "[$pkg] done ($REMOTE_PATH)"
        done
      '';
    };

    systemd.timers.store-sync = {
      description = "Periodically pull pre-built packages from remote builder";
      wantedBy = [ "timers.target" ];
      timerConfig = cfg.timerConfig;
    };
  };
}
