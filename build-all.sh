#!/usr/bin/env bash
set -euo pipefail

flake="$(cd "$(dirname "$0")" && pwd -P)"

# ─── Help ─────────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Evaluate and build all flake configurations (NixOS, home-manager, darwin),
optionally deploying to remote hosts.

Options:
  --eval                      Evaluate only; skip building and deploying.
  -d, --deploy-home HOST      Deploy the home-manager config for e@HOST via ssh.
                              Repeatable for multiple hosts.
  -D, --deploy-system HOST    Deploy the NixOS config for HOST via nixos-rebuild.
                              Repeatable for multiple hosts.
  -h, --help                  Show this help message.
EOF
}

# ─── Argument parsing ────────────────────────────────────────────────────────
eval_only=false
deploy_homes=()
deploy_systems=()

while (($#)); do
  case "$1" in
    --eval)
      eval_only=true
      shift
      ;;
    --deploy-home|-d)
      if [[ $# -lt 2 ]]; then
        echo "Error: $1 requires a HOST argument" >&2
        exit 1
      fi
      deploy_homes+=("$2")
      shift 2
      ;;
    --deploy-system|-D)
      if [[ $# -lt 2 ]]; then
        echo "Error: $1 requires a HOST argument" >&2
        exit 1
      fi
      deploy_systems+=("$2")
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

# ─── Buildable systems ───────────────────────────────────────────────────────
# Set of systems this Nix installation can build for, harvested from its own
# config: the local `system`, any `extra-platforms` (binfmt/qemu/native), and
# the systems advertised by any configured remote `builders`.
mapfile -t buildable_systems < <(
  cfg="$(nix config show --json 2>/dev/null || echo '{}')"
  printf '%s' "$cfg" | jq -r '
    # Parse builders into per-builder system lists. Builders may be a single
    # string, "@/path/to/file" pointing to a builders file, or a single
    # newline/semicolon-separated list. Each entry is space-separated fields:
    # uri systems sshKey maxJobs speed supportedFeatures mandatoryFeatures.
    def parse_builders(s):
      if (s|type) != "string" or (s|length) == 0 then []
      elif (s|startswith("@")) then
        # File reference; reading files isn'\''t supported here, skip.
        []
      else
        s
        | split("\n") | map(select(length > 0))
        | map(split(";")) | add // []
        | map(select(length > 0))
        | map(split(" +"; ""))
        | map(.[1] // "")
        | map(split(",")) | add // []
        | map(select(length > 0))
      end;
    [ .system.value ]
    + (."extra-platforms".value // [])
    + parse_builders(.builders.value)
    | unique | .[]
  '
)

contains() {
  local needle="$1"; shift
  local x
  for x in "$@"; do [[ "$x" == "$needle" ]] && return 0; done
  return 1
}

# ─── Evaluation ──────────────────────────────────────────────────────────────
# Single eval pass: return for every config across all known kinds the
# (system, attr-path-of-realisable-derivation, drvPath). Adding new kinds in
# future just means extending this expression. drvPath is included so the
# evaluation is forced for every target, surfacing eval errors regardless of
# whether we end up building.
all_json="$(nix eval --json --impure --expr "
  let
    flake = builtins.getFlake \"$flake\";
    kinds = [
      { kind = \"nixos\";  set = flake.nixosConfigurations  or {}; sysOf = c: c.pkgs.stdenv.hostPlatform.system; drvOf = c: c.config.system.build.toplevel.drvPath; }
      { kind = \"home\";   set = flake.homeConfigurations   or {}; sysOf = c: c.pkgs.stdenv.hostPlatform.system; drvOf = c: c.activationPackage.drvPath; }
      { kind = \"darwin\"; set = flake.darwinConfigurations or {}; sysOf = c: c.pkgs.stdenv.hostPlatform.system; drvOf = c: c.system.drvPath; }
    ];
  in builtins.concatMap (k:
    map (n: {
      kind = k.kind;
      name = n;
      sys  = k.sysOf k.set.\${n};
      drv  = k.drvOf k.set.\${n};
    }) (builtins.attrNames k.set)
  ) kinds
")"

n_total="$(printf '%s' "$all_json" | jq 'length')"
echo "Evaluated $n_total derivation(s)."

if $eval_only; then
  echo "Eval-only mode; stopping."
  exit 0
fi

echo "Local Nix can build for: ${buildable_systems[*]}"

targets=()
skipped=()
# Collect drv paths for deploy targets so we can reuse the eval.
declare -A home_drvs=()
declare -A nixos_drvs=()

while IFS=$'\t' read -r kind name sys drv; do
  [[ -z "$kind" ]] && continue
  if contains "$sys" "${buildable_systems[@]}"; then
    targets+=("$drv^*")
  else
    skipped+=("$kind:$name ($sys)")
  fi
  if [[ "$kind" == "home" ]]; then
    home_drvs["$name"]="$drv"
  elif [[ "$kind" == "nixos" ]]; then
    nixos_drvs["$name"]="$drv"
  fi
done < <(printf '%s' "$all_json" | jq -r '.[] | [.kind, .name, .sys, .drv] | @tsv')

if ((${#skipped[@]})); then
  echo "Skipping ${#skipped[@]} target(s) for unsupported systems:"
  printf '  - %s\n' "${skipped[@]}"
fi

if ((${#targets[@]} == 0)); then
  echo "No buildable targets."
  exit 0
fi

echo "Building ${#targets[@]} target(s)."
nom build --keep-going --no-link "${targets[@]}"

# ─── Deploy homes ────────────────────────────────────────────────────────────
for h in "${deploy_homes[@]}"; do
  drv="${home_drvs["e@$h"]:-}"
  if [[ -z "$drv" ]]; then
    echo "Error: no home configuration found for e@$h" >&2
    exit 1
  fi
  out="$(nix derivation show "$drv" | jq -r '.[].outputs.out.path')"
  echo "Deploying home configuration for e@$h ($out)..."
  nix copy --to "ssh://$h" "$out"
  # shellcheck disable=SC2029
  ssh "$h" "$out/activate"
done

# ─── Deploy systems ──────────────────────────────────────────────────────────
for h in "${deploy_systems[@]}"; do
  drv="${nixos_drvs["$h"]:-}"
  if [[ -z "$drv" ]]; then
    echo "Error: no NixOS configuration found for $h" >&2
    exit 1
  fi
  out="$(nix derivation show "$drv" | jq -r '.[].outputs.out.path')"
  echo "Deploying NixOS configuration for $h ($out)..."
  nix copy --to "ssh://$h" "$out"
  nixos-rebuild switch --store-path "$out" --target-host "$h" --sudo --ask-sudo-password
done
