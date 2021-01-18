#!/usr/bin/env bash
# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include doc
@include commands
@include log

@package docker

function docker::cmd() {
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
