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

# Function to modify arguments
modify_args() {
  local args=()
  while (($#)); do
    local arg="$1"
    # Replace main@xxx with master@xxx if master@xxx exists and main@xxx doesn't
    if [[ "$arg" == "main@"* ]]; then
      local remote="${arg#main@}"
      if master_exists_for_remote "$remote" && ! branch_exists "$arg"; then
        echo -e "\033[90mreplacing $arg with master@$remote\033[0m" >&2
        args+=("master@$remote")
      else
        args+=("$arg")
      fi
    # Handle github-style branch references
    elif [[ "$arg" =~ ^([^:]+):([^:]+)$ ]]; then
      local owner="${BASH_REMATCH[1]}"
      local branch="${BASH_REMATCH[2]}"
      if remote_exists "$owner"; then
        echo -e "\033[90mreplacing $arg with ${branch}@${owner}\033[0m" >&2
        args+=("${branch}@${owner}")
      else
        args+=("$arg")
      fi
    else
      args+=("$arg")
    fi
    shift
  done
  printf '%s\n' "${args[@]}"
}

# Get modified arguments
declare -a modified_args
if [ $# -eq 0 ]; then
  exec "@jj_binary@"
else
  readarray -t modified_args < <(modify_args "$@")
  exec "@jj_binary@" "${modified_args[@]}"
fi
