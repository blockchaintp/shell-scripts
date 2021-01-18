#!/usr/bin/env bash
# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include doc
@include log

@package annotations

function annotations::deprecated() {
  @doc Mark a function as deprecated
  local newfunc=$1
  log::debug "${FUNCNAME[1]} is deprecated. Replace with $newfunc"
  "$@"
}
function deprecated() {
  annotations::deprecated "$@"
}
