#!/bin/bash

src_name=include_$(sha256sum "${BASH_SOURCE[0]}" | awk '{print $1}')
if [ -z "${!src_name}" ]; then
  declare -g "$src_name=${src_name}"
else
  return
fi

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"

@package docker

function docker::pull() {
  @doc pull the specified image
  @arg _1_ the full image url to pull
  local image=${1:?}
  log::info "Pulling $image"
  exec::hide docker pull -q "$image"
}

function docker::tag() {
  @doc retag one image to the provided url
  @arg _1_ the full image url of the script
  @arg _2_ the desired final url
  local from=${1:?}
  local to=${2:?}
  exec::hide docker tag "$from" "$to"
}

function docker::push() {
  @doc push the specified image
  @arg _1_ the full image url to push
  local image=${1:?}
  log::info "Pushing $image"
  exec::hide docker push "$image"
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
