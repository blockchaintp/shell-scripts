#!/bin/bash

# dirs.sh must be co-resident with this file
# shellcheck source=dirs.sh
source "$(dirname "${BASH_SOURCE[0]}")/dirs.sh"
DIR=$(dirs::of)

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"

# shellcheck source=annotations.sh
source "$DIR/annotations.sh"

@package exec

function exec::capture() {
  @doc Execute the provided command and capture the output to a log
  local logfile=${LOGFILE:-"exec.log"}
  "$@" 2>&1 | tee -a "$logfile"
  exit_code=${PIPESTATUS[0]}
  # shellcheck disable=SC2086
  return ${exit_code}
}
function exec_and_capture() {
  @doc Deprecated in favor of exec::capture
  deprecated exec::capture "$@"
}

function exec::hide() {
  @doc Execute the provided command and swallow the output
  "$@" >/dev/null 2>&1
}
function exec_and_hide() {
  @doc Deprecated in favor of exec::hide
  deprecated exec::hide "$@"
}
