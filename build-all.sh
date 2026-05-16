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
# Step 1: discover config names from the snowfall-lib directory structure.
# Layout: systems/<arch>/<name>/  homes/<arch>/<name>/
declare -A config_names=()  # "kind:name" -> system
for dir in "$flake"/systems/*/; do
  [[ -d "$dir" ]] || continue
  sys="$(basename "$dir")"
  for cfg in "$dir"*/; do
    [[ -d "$cfg" ]] || continue
    config_names["nixos:$(basename "$cfg")"]="$sys"
  done
done
for dir in "$flake"/homes/*/; do
  [[ -d "$dir" ]] || continue
  sys="$(basename "$dir")"
  for cfg in "$dir"*/; do
    [[ -d "$cfg" ]] || continue
    config_names["home:$(basename "$cfg")"]="$sys"
  done
done

# Step 2: eval each config in parallel. Each writes a JSON result (or error
# log) to a temp file. We track PIDs to wait on and collect results.
eval_tmpdir="$(mktemp -d)"
trap 'rm -rf "$eval_tmpdir"' EXIT

declare -A eval_pids=()  # "kind:name" -> pid

eval_one() {
  local kind="$1" name="$2" outfile="$3" errfile="$4"
  local nix_name
  # Quote the name for nix attribute access (handles @ and other special chars).
  nix_name="\"$name\""
  local expr
  case "$kind" in
    nixos)  expr="let f = builtins.getFlake \"$flake\"; c = f.nixosConfigurations.$nix_name; in c.config.system.build.toplevel.drvPath" ;;
    home)   expr="let f = builtins.getFlake \"$flake\"; c = f.homeConfigurations.$nix_name; in c.activationPackage.drvPath" ;;
    darwin) expr="let f = builtins.getFlake \"$flake\"; c = f.darwinConfigurations.$nix_name; in c.system.drvPath" ;;
  esac
  nix eval --json --impure --expr "$expr" > "$outfile" 2> "$errfile"
}

n_total=0
for key in "${!config_names[@]}"; do
  kind="${key%%:*}"
  name="${key#*:}"
  outfile="$eval_tmpdir/$kind-$name.json"
  errfile="$eval_tmpdir/$kind-$name.err"
  eval_one "$kind" "$name" "$outfile" "$errfile" &
  eval_pids["$key"]=$!
  ((n_total++)) || true
done

# Wait for all evals and collect results.
eval_failures=()
all_results=()
declare -A home_drvs=()
declare -A nixos_drvs=()

for key in "${!eval_pids[@]}"; do
  pid="${eval_pids[$key]}"
  kind="${key%%:*}"
  name="${key#*:}"
  sys="${config_names[$key]}"
  outfile="$eval_tmpdir/$kind-$name.json"
  errfile="$eval_tmpdir/$kind-$name.err"

  if wait "$pid"; then
    drv="$(jq -r '.' < "$outfile")"
    all_results+=("$kind"$'\t'"$name"$'\t'"$sys"$'\t'"$drv")
    if [[ "$kind" == "home" ]]; then
      home_drvs["$name"]="$drv"
    elif [[ "$kind" == "nixos" ]]; then
      nixos_drvs["$name"]="$drv"
    fi
  else
    eval_failures+=("$key")
    echo "EVAL FAILED: $key" >&2
    cat "$errfile" >&2
  fi
done

if ((${#eval_failures[@]})); then
  printf '  - %s\n' "${eval_failures[@]}" >&2
  exit 1
fi

if $eval_only; then
  exit 0
fi

targets=()
for entry in "${all_results[@]}"; do
  IFS=$'\t' read -r kind name sys drv <<< "$entry"
  if contains "$sys" "${buildable_systems[@]}"; then
    targets+=("$drv^*")
  fi
done

if ((${#targets[@]} == 0)); then
  echo "No buildable targets." >&2
  exit 0
fi

nom build --keep-going --no-link "${targets[@]}"

# ─── Deploy homes ────────────────────────────────────────────────────────────
for h in "${deploy_homes[@]}"; do
  drv="${home_drvs["e@$h"]:-}"
  if [[ -z "$drv" ]]; then
    echo "Error: no home configuration found for e@$h" >&2
    exit 1
  fi
  out="$(nix derivation show "$drv" | jq -r '.[].outputs.out.path')"
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
  nix copy --to "ssh://$h" "$out"
  nixos-rebuild switch --store-path "$out" --target-host "$h" --sudo --ask-sudo-password
done
