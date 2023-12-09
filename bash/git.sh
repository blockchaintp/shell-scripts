#!/usr/bin/env bash
# Copyright © 2023 Paravela Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------------

# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include commands
@include doc

@package git

function git::cmd() {
  @doc Smart command for git.
  @arg @ args to git
  $(commands::use git) "$@"
}

function git::tagsinhistory() {
  @doc List all the tags in the history of this commit.
  git::cmd log --no-walk --pretty="%d" -n 100000 | grep "(tag" |
    awk '{print $2}' | sed -e 's/)//' |
    awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }' |
    sed -e 's/,$//'
}

function git::projecturl() {
  @doc Get the project url of this git repository.
  local origin_url
  origin_url=$(git remote -v | grep "^origin" | head -1)
  if echo "$origin_url" | grep -q github; then
    local project_url
    project_url=$(echo "$origin_url" | awk '{print $2}')
    project_url=${project_url//.git/}
    project_url=${project_url//git@github.com:/}
    project_url=${project_url//https:\/\/github.com\//}
    project_url=${project_url//http:\/\/github.com\//}
    echo "https://github.com/$project_url/commit"
  fi
}

function git::commits() {
  @doc List the git commits between two commits.
  @arg _1_ from
  @arg _2_ to
  local from=$1
  local to=$2
  [ -z "$to" ] && to="HEAD"
  git::cmd log "$from"..."$to" --pretty=format:'%h'
}

function git::log_fromto() {
  @doc Get the log messages from one commit ending at another.
  @arg _1_ from
  @arg _2_ to
  local from=$1
  local to=$2
  [ -z "$to" ] && to="HEAD"
  git::cmd log "$from"..."$to" --no-merges --pretty=format:"* %h %s"
}

function git::files_changed() {
  @doc List the files changed in a commit.
  @arg _1_ the commit to examine
  local commit=$1
  git::cmd diff-tree --no-commit-id --name-only -r "$commit" | sort
}

function git::describe() {
  @doc Smart command for git::cmd describe.
  git::cmd describe "$@"
}

function git::dirty_version() {
  @doc Get what the dirty version would be for the current repository.
  echo "$(git::describe --tags 2>/dev/null)-dirty"
}
