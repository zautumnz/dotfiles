#!/bin/sh

remote="${1:-origin}"

# check if output is a terminal for color
if [ -t 1 ]; then
  reset="$(printf '\033[0m')"
  green="$(printf '\033[0;32m')"
  yellow="$(printf '\033[0;33m')"
  red="$(printf '\033[0;31m')"
else
  reset=""
  green=""
  yellow=""
  red=""
fi

# ensure we are in a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 1
fi

# try to fetch but allow failure
git fetch --all 2>/dev/null

current_branch="$(git rev-parse --abbrev-ref HEAD)"

# get and clean remote branches
remote_branches=$(git branch -r | sed "s|^ *${remote}/||" | sed '/->/d' | sed 's/^ *//')

# get and clean local branches
local_branches=$(git branch | sed 's/^[* ]*//' | sed '/^$/d')

# combine and deduplicate all branches
all_branches=$(printf "%s\n%s\n" "$remote_branches" "$local_branches" | sort -u)

# loop through each branch and annotate
printf "%s\n" "$all_branches" | while IFS= read -r branch; do
  prefix="  "
  [ "$branch" = "$current_branch" ] && prefix="* "

  echo "$local_branches" | grep -qx "$branch" && is_local=true || is_local=false
  echo "$remote_branches" | grep -qx "$branch" && is_remote=true || is_remote=false

  if [ "$is_local" = true ] && [ "$is_remote" = true ]; then
    printf "%s%s%s (both)%s\n" "$green" "$prefix" "$branch" "$reset"
  elif [ "$is_local" = true ]; then
    printf "%s%s%s (local)%s\n" "$red" "$prefix" "$branch" "$reset"
  elif [ "$is_remote" = true ]; then
    printf "%s%s%s (remote)%s\n" "$yellow" "$prefix" "$branch" "$reset"
  fi
done
