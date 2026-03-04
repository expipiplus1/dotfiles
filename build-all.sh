#!/usr/bin/env bash
set -euo pipefail

flake="$(cd "$(dirname "$0")" && pwd -P)"

mapfile -t systems < <(nix eval "$flake#nixosConfigurations" --apply builtins.attrNames --json 2>/dev/null | jq -r '.[]')
mapfile -t homes < <(nix eval "$flake#homeConfigurations" --apply builtins.attrNames --json 2>/dev/null | jq -r '.[]')

targets=()
for s in "${systems[@]}"; do
  targets+=("$flake#nixosConfigurations.$s.config.system.build.toplevel")
done
for h in "${homes[@]}"; do
  targets+=("$flake#homeConfigurations.\"$h\".activationPackage")
done

echo "Building ${#systems[@]} systems and ${#homes[@]} homes (${#targets[@]} targets)"
exec nom build --no-link "${targets[@]}"
