#!/usr/bin/env bash

# Check if we're in a Jujutsu repo
is_jj_repo() {
  local current_dir="$PWD"
  while [[ "$current_dir" != "/" ]]; do
    if [[ -d "$current_dir/.jj" ]]; then
      return 0
    fi
    current_dir="$(dirname "$current_dir")"
  done
  return 1
}

# If not in a Jujutsu repo, pass arguments directly to jj
if ! is_jj_repo; then
  exec "@jj_binary@" "$@"
fi

# Function to check if a branch exists
branch_exists() {
  local branch=$1
  "@jj_binary@" bookmark list --tracked --template 'name++"@"++remote++"\n"' | grep -q "^$branch$"
}

# Function to check if master branch exists for a remote
master_exists_for_remote() {
  local remote=$1
  "@jj_binary@" bookmark list --tracked --template 'name++"@"++remote++"\n"' | grep -q "^master@$remote$"
}

# Function to check if remote exists
remote_exists() {
  local remote=$1
  "@jj_binary@" git remote list | cut -d' ' -f1 | grep -q "^${remote}$"
}

# Function to modify arguments and output them null-terminated
modify_args() {
  local skip_next=false
  while (($#)); do
    local arg="$1"

    # Don't transform values of string-valued flags
    if $skip_next; then
      skip_next=false
      printf "%s\0" "$arg"
      shift
      continue
    fi

    # Flags whose next argument is a literal value, not a revset
    case "$arg" in
      -m|--message|-d|--description)
        skip_next=true
        printf "%s\0" "$arg"
        shift
        continue
        ;;
    esac

    local prefix=""
    local suffix=""
    local core=""

    if [[ "$arg" =~ ^(::)?([^:]+)(::)?$ ]]; then
      prefix="${BASH_REMATCH[1]}"
      core="${BASH_REMATCH[2]}"
      suffix="${BASH_REMATCH[3]}"
    else
      core="$arg"
    fi

    local processed_core="$core"

    if [[ "$core" == "main@"* ]]; then
      local remote="${core#main@}"
      if master_exists_for_remote "$remote" && ! branch_exists "$core"; then
        echo -e "\033[90mreplacing $core with master@$remote\033[0m" >&2
        processed_core="master@$remote"
      fi
    elif [[ "$core" =~ ^([^:]+):([^:]+)$ ]]; then
      local owner="${BASH_REMATCH[1]}"
      local branch="${BASH_REMATCH[2]}"
      if remote_exists "$owner"; then
        echo -e "\033[90mreplacing $core with ${branch}@${owner}\033[0m" >&2
        processed_core="${branch}@${owner}"
      fi
    fi

    # Output the argument followed by a null byte
    printf "%s\0" "${prefix}${processed_core}${suffix}"
    shift
  done
}

if [ $# -eq 0 ]; then
  exec "@jj_binary@"
else
  # Use -d '' to read until null bytes, preserving newlines within arguments
  declare -a modified_args=()
  while IFS= read -r -d '' item; do
    modified_args+=("$item")
  done < <(modify_args "$@")

  exec "@jj_binary@" "${modified_args[@]}"
fi
