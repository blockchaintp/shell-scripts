#!/bin/bash

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"
# shellcheck source=bash-logger.sh
source "$(dirname "${BASH_SOURCE[0]}")/bash-logger.sh"
@package .

function deprecated() {
  @doc Mark a function as deprecateds
  local newfunc=$1
  DEBUG "${FUNCNAME[1]} is deprecated. Replace with $newfunc"
  "$@"
}
