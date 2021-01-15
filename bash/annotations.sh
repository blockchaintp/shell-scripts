#!/bin/bash

src_name=include_$(sha256sum "${BASH_SOURCE[0]}" | awk '{print $1}')
if [ -z "${!src_name}" ]; then
  declare -g "$src_name=${src_name}"
else
  return
fi

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"

# shellcheck source=bash-logger.sh
source "$(dirname "${BASH_SOURCE[0]}")/bash-logger.sh"
@package .

function deprecated() {
  @doc Mark a function as deprecateds
  local newfunc=$1
  log::debug "${FUNCNAME[1]} is deprecated. Replace with $newfunc"
  "$@"
}
