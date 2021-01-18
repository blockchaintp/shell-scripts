#!/usr/bin/env bash
# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

include doc
include bash-logger

@package .

function deprecated() {
  @doc Mark a function as deprecated
  local newfunc=$1
  log::debug "${FUNCNAME[1]} is deprecated. Replace with $newfunc"
  "$@"
}
