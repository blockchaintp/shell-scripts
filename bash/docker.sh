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
