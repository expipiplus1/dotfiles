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
  exit $?
fi

# Function to check if a branch exists
branch_exists() {
  local branch=$1
  local remote_branches
  remote_branches=$("@jj_binary@" bookmark list --tracked --template 'name++"@"++remote++"\n"')
  echo "$remote_branches" | grep -q "^$branch$"
}

# Function to check if master branch exists for a remote
master_exists_for_remote() {
  local remote=$1
  local remote_branches
  remote_branches=$("@jj_binary@" bookmark list --tracked --template 'name++"@"++remote++"\n"')
  echo "$remote_branches" | grep -q "^master@$remote$"
}

# Function to check if remote exists
remote_exists() {
  local remote=$1
  "@jj_binary@" git remote list | cut -d' ' -f1 | grep -q "^${remote}$"
}

# Process arguments directly without intermediate storage
if [ $# -eq 0 ]; then
  exec "@jj_binary@"
else
  # Build modified arguments array directly
  modified_args=()
  while (($#)); do
    arg="$1"
    prefix=""
    suffix=""
    core=""

    # Extract prefix (::) and suffix (::) if present
    if [[ "$arg" =~ ^(::)?([^:]+)(::)?$ ]]; then
      prefix="${BASH_REMATCH[1]}"
      core="${BASH_REMATCH[2]}"
      suffix="${BASH_REMATCH[3]}"
    else
      core="$arg"
    fi

    # Process the core part
    processed_core="$core"

    # Replace main@xxx with master@xxx if master@xxx exists and main@xxx doesn't
    if [[ "$core" == "main@"* ]]; then
      remote="${core#main@}"
      if master_exists_for_remote "$remote" && ! branch_exists "$core"; then
        echo -e "\033[90mreplacing $core with master@$remote\033[0m" >&2
        processed_core="master@$remote"
      fi
    # Handle github-style branch references
    elif [[ "$core" =~ ^([^:]+):([^:]+)$ ]]; then
      owner="${BASH_REMATCH[1]}"
      branch="${BASH_REMATCH[2]}"
      if remote_exists "$owner"; then
        echo -e "\033[90mreplacing $core with ${branch}@${owner}\033[0m" >&2
        processed_core="${branch}@${owner}"
      fi
    fi

    # Add the processed argument directly to the array
    modified_args+=("${prefix}${processed_core}${suffix}")
    shift
  done

  exec "@jj_binary@" "${modified_args[@]}"
fi
