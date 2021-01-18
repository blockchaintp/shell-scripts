#!/usr/bin/env bash
# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include doc
@include annotations

@package exec

function exec::capture() {
  @doc Execute the provided command and capture the output to a log
  if [ -n "$LOGFILE_DISABLE" ]; then
    local logfile=${LOGFILE:-"exec.log"}
    "$@" 2>&1 | tee -a "$logfile"
    exit_code=${PIPESTATUS[0]}
  else
    "$@" 2>&1
    exit_code=$?
  fi
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
