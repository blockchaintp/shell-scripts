#!/usr/bin/env bash

src_name=include_$(sha256sum "${BASH_SOURCE[0]}" | awk '{print $1}')
if [ -z "${!src_name}" ]; then
  declare -g "$src_name=${src_name}"
else
  return
fi

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"

# dirs.sh must be co-resident with this file
# shellcheck source=dirs.sh
source "$(dirname "${BASH_SOURCE[0]}")/dirs.sh"
DIR=$(dirs::of)

# shellcheck source=annotations.sh
source "$DIR/annotations.sh"

@package git

function git::tagsinhistory() {
  git log --no-walk --pretty="%d" -n 100000 | grep "(tag" | awk '{print $2}' |
    sed -e 's/)//' | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }'
}

function git::projecturl() {
  local origin_url
  origin_url=$(git remote -v | grep "^origin" | head -1)
  if echo "$origin_url" | grep -q github; then
    local project_url
    project_url=$(echo "$origin_url" | awk '{print $2}')
    project_url=${project_url//.git/}
    project_url=${project_url//git@github.com:/}
    echo "http://github.com/$project_url/commit"
  fi
}

function git::commits() {
  local from=$1
  local to=$2
  [ -z "$to" ] && to="HEAD"
  git log "$from"..."$to" --pretty=format:'%h'
}

function git::log_fromto() {
  local from=$1
  local to=$2
  [ -z "$to" ] && to="HEAD"
  git log "$from"..."$to" --no-merges --pretty=format:"* %h %s"
}

function git::files_changed() {
  local commit=$1
  git diff-tree --no-commit-id --name-only -r "$commit" | sort
}
