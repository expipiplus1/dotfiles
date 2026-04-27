#!/usr/bin/env bash
set -euo pipefail

flake="$(cd "$(dirname "$0")" && pwd -P)"

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
        # File reference; reading files isn''t supported here, skip.
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

# Single eval pass: return for every config across all known kinds the
# (system, attr-path-of-realisable-derivation, drvPath). Adding new kinds in
# future just means extending this expression. drvPath is included so the
# evaluation is forced for every target, surfacing eval errors regardless of
# whether we end up building.
all_json="$(nix eval --json --impure --expr "
  let
    flake = builtins.getFlake \"$flake\";
    kinds = [
      { kind = \"nixos\";  set = flake.nixosConfigurations  or {}; sysOf = c: c.pkgs.stdenv.hostPlatform.system; attrFmt = n: ''nixosConfigurations.\"\${n}\".config.system.build.toplevel''; drvOf = c: c.config.system.build.toplevel.drvPath; }
      { kind = \"home\";   set = flake.homeConfigurations   or {}; sysOf = c: c.pkgs.stdenv.hostPlatform.system; attrFmt = n: ''homeConfigurations.\"\${n}\".activationPackage'';            drvOf = c: c.activationPackage.drvPath; }
      { kind = \"darwin\"; set = flake.darwinConfigurations or {}; sysOf = c: c.pkgs.stdenv.hostPlatform.system; attrFmt = n: ''darwinConfigurations.\"\${n}\".system'';                    drvOf = c: c.system.drvPath; }
    ];
  in builtins.concatMap (k:
    map (n: {
      kind = k.kind;
      name = n;
      sys  = k.sysOf k.set.\${n};
      attr = k.attrFmt n;
      drv  = k.drvOf k.set.\${n};
    }) (builtins.attrNames k.set)
  ) kinds
")"

n_total="$(printf '%s' "$all_json" | jq 'length')"
echo "Evaluated $n_total derivation(s)."
echo "Local Nix can build for: ${buildable_systems[*]}"

targets=()
skipped=()
while IFS=$'\t' read -r kind name sys attr; do
  [[ -z "$kind" ]] && continue
  if contains "$sys" "${buildable_systems[@]}"; then
    targets+=("$flake#$attr")
  else
    skipped+=("$kind:$name ($sys)")
  fi
done < <(printf '%s' "$all_json" | jq -r '.[] | [.kind, .name, .sys, .attr] | @tsv')

if ((${#skipped[@]})); then
  echo "Skipping ${#skipped[@]} target(s) for unsupported systems:"
  printf '  - %s\n' "${skipped[@]}"
fi

if ((${#targets[@]} == 0)); then
  echo "No buildable targets."
  exit 0
fi

echo "Building ${#targets[@]} target(s)."
exec nom build --keep-going --no-link "${targets[@]}"
