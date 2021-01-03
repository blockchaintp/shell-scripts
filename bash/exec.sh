#!/bin/bash

# dirs.sh must be co-resident with this file
# shellcheck source=dirs.sh
source "$(dirname "${BASH_SOURCE[0]}")/dirs.sh"
DIR=$(dirs::of)

# shellcheck source=annotations.sh
source "$DIR/annotations.sh"

function exec::capture() {
  local logfile=${LOGFILE:-"exec.log"}
  "$@" 2>&1 | tee -a "$logfile"
  exit_code=${PIPESTATUS[0]}
  # shellcheck disable=SC2086
  return ${exit_code}
}
function exec_and_capture() {
  deprecated exec::capture "$@"
}

function exec::hide() {
  "$@" >/dev/null 2>&1
}
function exec_and_hide() {
  deprecated exec::hide "$@"
}
