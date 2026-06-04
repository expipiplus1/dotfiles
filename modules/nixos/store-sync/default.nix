{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.ellie.store-sync;
  stateDir = "/var/lib/store-sync";

  remoteModule = types.submodule {
    options = {
      remoteSSH = mkOption {
        type = types.str;
        description = "SSH user@host for the remote builder (e.g. e@haku).";
      };

      remotePort = mkOption {
        type = types.int;
        default = 22;
        description = "SSH port for the remote builder.";
      };

      remoteStateDir = mkOption {
        type = types.str;
        default = "/var/lib/background-builder";
        description = "StateDirectory on the remote where build manifests are stored.";
      };

      packages = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Package names to pull (must match background-builder package names).";
      };
    };
  };

  sshOptsFor = remote: concatStringsSep " " [
    "-i ${escapeShellArg cfg.sshKeyFile}"
    "-p ${toString remote.remotePort}"
    "-o ConnectTimeout=10"
    "-o StrictHostKeyChecking=accept-new"
    "-o BatchMode=yes"
  ];

  storeURIFor = remote:
    "ssh://${remote.remoteSSH}:${toString remote.remotePort}?ssh-key=${cfg.sshKeyFile}";

  syncScriptFor = name: remote: ''
    echo "=== Syncing from ${name} (${remote.remoteSSH}) ==="
    for pkg in ${escapeShellArgs remote.packages}; do
      echo "[$pkg] checking remote manifest..."

      # Read the store path the builder recorded
      REMOTE_PATH=$(ssh ${sshOptsFor remote} ${escapeShellArg remote.remoteSSH} \
        "cat ${escapeShellArg remote.remoteStateDir}/latest-paths/$pkg" 2>/dev/null) || {
        echo "[$pkg] WARNING: could not read manifest from ${name} (unreachable or not built yet)"
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
        nix copy --from ${escapeShellArg (storeURIFor remote)} "$REMOTE_PATH" || {
          echo "[$pkg] WARNING: failed to copy from ${name}"
          continue
        }
      fi

      # Create/update GC root (replaces previous version automatically)
      nix-store --realise "$REMOTE_PATH" --add-root "${stateDir}/roots/$pkg" --indirect

      echo "[$pkg] done ($REMOTE_PATH)"
    done
  '';

in {
  options.ellie.store-sync = {
    enable = mkEnableOption "periodic syncing of pre-built store paths from remote builders";

    remotes = mkOption {
      type = types.attrsOf remoteModule;
      default = { };
      description = "Named remote builders to sync packages from.";
    };

    sshKeyFile = mkOption {
      type = types.str;
      description = "Path to SSH private key for connecting to builders.";
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
      description = "Pull pre-built packages from remote builders";
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

        # Fail fast if SSH key is missing rather than silently failing every package
        if [ ! -f ${escapeShellArg cfg.sshKeyFile} ]; then
          echo "FATAL: SSH key not found at ${cfg.sshKeyFile}"
          exit 1
        fi

        mkdir -p ${stateDir}/roots

        ${concatStringsSep "\n" (mapAttrsToList syncScriptFor cfg.remotes)}
      '';
    };

    systemd.timers.store-sync = {
      description = "Periodically pull pre-built packages from remote builders";
      wantedBy = [ "timers.target" ];
      timerConfig = cfg.timerConfig;
    };
  };
}
