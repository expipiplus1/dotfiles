#!/usr/bin/env bash
set -euo pipefail

flake="$(cd "$(dirname "$0")" && pwd -P)"

current="$(nix eval --impure --raw --expr 'builtins.currentSystem')"

# Decide whether a target system can be built locally.
# Skip cross-OS (linux<->darwin); allow same-OS arch differences (cross/emulation
# may still work, and remote builders can pick them up).
buildable() {
  local target="$1"
  case "$current:$target" in
    *linux:*darwin|*darwin:*linux) return 1 ;;
    *) return 0 ;;
  esac
}

# Per-kind: name -> { sys, attr } where attr is the flake attr path of the
# realisable derivation. We evaluate ALL of them (forcing eval of every
# derivation), then filter for which ones we actually try to build.
nixos_json="$(nix eval --json "$flake#nixosConfigurations" \
  --apply 'cfgs: builtins.mapAttrs (n: c: {
    sys = c.pkgs.stdenv.hostPlatform.system;
    attr = "nixosConfigurations.\"" + n + "\".config.system.build.toplevel";
  }) cfgs' 2>/dev/null || echo '{}')"

home_json="$(nix eval --json "$flake#homeConfigurations" \
  --apply 'cfgs: builtins.mapAttrs (n: c: {
    sys = c.pkgs.stdenv.hostPlatform.system;
    attr = "homeConfigurations.\"" + n + "\".activationPackage";
  }) cfgs' 2>/dev/null || echo '{}')"

darwin_json="$(nix eval --json "$flake#darwinConfigurations" \
  --apply 'cfgs: builtins.mapAttrs (n: c: {
    sys = (c.config.nixpkgs.hostPlatform.system or c.pkgs.stdenv.hostPlatform.system);
    attr = "darwinConfigurations.\"" + n + "\".system";
  }) cfgs' 2>/dev/null || echo '{}')"

# Combine into a single list of "kind\tname\tsys\tattr" lines.
all="$(jq -rn \
  --argjson nixos "$nixos_json" \
  --argjson home "$home_json" \
  --argjson darwin "$darwin_json" \
  '
    [ ($nixos  | to_entries[] | {kind:"nixos",  name:.key, sys:.value.sys, attr:.value.attr})
    , ($home   | to_entries[] | {kind:"home",   name:.key, sys:.value.sys, attr:.value.attr})
    , ($darwin | to_entries[] | {kind:"darwin", name:.key, sys:.value.sys, attr:.value.attr})
    ] | .[] | [.kind, .name, .sys, .attr] | @tsv
  ')"

# Phase 1: evaluate every derivation (drvPath) so eval errors surface even for
# targets we will not build.
n_total="$(printf '%s\n' "$all" | grep -c . || true)"
if (( n_total > 0 )); then
  echo "Evaluating $n_total derivations..."
  nix eval --json "$flake" --apply '
    flake: let
      n = builtins.mapAttrs (_: c: c.config.system.build.toplevel.drvPath) (flake.nixosConfigurations or {});
      h = builtins.mapAttrs (_: c: c.activationPackage.drvPath)             (flake.homeConfigurations or {});
      d = builtins.mapAttrs (_: c: c.system.drvPath)                        (flake.darwinConfigurations or {});
    in { nixos = n; home = h; darwin = d; }
  ' >/dev/null
fi

# Phase 2: pick buildable ones.
targets=()
skipped=()
while IFS=$'\t' read -r kind name sys attr; do
  [[ -z "$kind" ]] && continue
  if buildable "$sys"; then
    targets+=("$flake#$attr")
  else
    skipped+=("$kind:$name ($sys)")
  fi
done <<< "$all"

if ((${#skipped[@]})); then
  echo "Skipping ${#skipped[@]} unbuildable on $current (evaluated only):"
  printf '  - %s\n' "${skipped[@]}"
fi

if ((${#targets[@]} == 0)); then
  echo "No buildable targets for $current."
  exit 0
fi

echo "Building ${#targets[@]} targets on $current"
exec nom build --keep-going --no-link "${targets[@]}"
