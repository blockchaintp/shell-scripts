#!/bin/bash

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"
@package .

function deprecated() {
  @doc Mark a function as deprecateds
  local newfunc=$1
  echo "${FUNCNAME[1]} is deprecated. Replace with $newfunc"
  "$@"
}
