#!/usr/bin/env bash
# Copyright 2021 Blockchain Technology Partners
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
@include log

@package docker

function docker::cmd() {
  @doc Smart command for docker.
  $(commands::use docker) "$@"
}

function docker::pull() {
  @doc pull the specified image
  @arg _1_ the full image url to pull
  local image=${1:?}
  log::info "Pulling $image"
  exec::hide docker::cmd pull -q "$image"
}

function docker::tag() {
  @doc retag one image to the provided url
  @arg _1_ the full image url of the script
  @arg _2_ the desired final url
  local from=${1:?}
  local to=${2:?}
  exec::hide docker::cmd tag "$from" "$to"
}

function docker::push() {
  @doc push the specified image
  @arg _1_ the full image url to push
  local image=${1:?}
  log::info "Pushing $image"
  exec::hide docker::cmd push "$image"
}

function docker::cp() {
  @doc copy an image from one image url to another
  @arg _1_ source
  @arg _2_ destination
  local from=${1:?}
  local to=${2:?}
  if docker::pull "$from"; then
    if docker::tag "$from" "$to"; then
      if docker::push "$to"; then
        return 0
      else
        exit_code=$?
        log::debug "Failed exit_code=$exit_code push $to"
        return 3
      fi
    else
      exit_code=$?
      log::debug "Failed exit_code=$exit_code tag from as $to"
      return 2
    fi
  else
    exit_code=$?
    log::debug "Failed exit_code=$exit_code pull $from"
    return 1
  fi
}

function docker::login() {
  local docker_user=${1:?}
  local docker_pass=${2:?}
  local registry=${3}

  echo "$docker_pass" | docker::cmd login -u "$docker_user" --password-stdin \
    "$registry"
}

function docker::registrycmd {
  local url=${1:?}
  local registry=${2:?}
  local basic_token
  basic_token=$(jq -r ".auths.\"$registry\".auth" ~/.docker/config.json)
  $(commands::use curl) -s -H "Authorization: Basic $basic_token" "https://$registry/v2/$url"
}

function docker::list_repositories {
  local registry=${1:?}
  docker::registrycmd _catalog "$registry" | jq -r '.repositories[]' |
    sort
}

function docker::list_tags {
  local repository=${1:?}
  local registry=${2?}
  docker::registrycmd "$repository/tags/list" "$registry" | jq -r '.tags[]' |
    sort -V
}

function docker::list_versions {
  local repository=${1:?}
  local registry=${2?}
  docker::list_tags "$repository" "$registry" |
    grep -E 'BTP[0-9]+.[0-9]+.[0-9]+(rc[0-9]+)?(-[0-9]+-[a-z0-9]{8,10})?(-[0-9]+.[0-9]+.[0-9]+(p[0-9]+(-[0-9]+-[a-z0-9]{8,10})?)?)?' |
    sort -V
}

function docker::list_official_versions {
  local repository=${1:?}
  local registry=${2?}
  docker::list_tags "$repository" "$registry" | grep -E \
    '^BTP[0-9]+.[0-9]+.[0-9]+(rc[0-9]+)?(-[0-9]+.[0-9]+.[0-9]+(p[0-9]+)?)?$' |
    sort -V
}

function docker::promote_latest() {
  local organization=${1:?}
  local registry=${2?}
  local target_tag=${3:?}
  shift 3

  for repo in $(docker::list_repositories "$registry" |
    grep "^${organization}/"); do
    local src_version
    src_version=$(docker::list_official_versions "$repo" "$registry" | grep "^${target_tag}-" | sort -V |
      tail -1)
    if [ -z "$src_version" ]; then
      log::warn "$repo has no official version in $target_tag"
      continue
    fi
    docker::cp "$registry/$repo:$src_version" "$registry/$repo:$target_tag"
    for extra_registry in "$@"; do
      docker::tag "$registry/$repo:$src_version" "$extra_registry/$repo:$src_version"
      docker::tag "$registry/$repo:$target_tag" "$extra_registry/$repo:$target_tag"
    done
    for extra_registry in "$@"; do
      docker::push "$extra_registry/$repo:$src_version"0
      docker::push "$extra_registry/$repo:$target_tag"
    done
  done
}
