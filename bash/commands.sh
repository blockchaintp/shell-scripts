#!/usr/bin/env bash
# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include doc
@include log

@package commands

function commands::err_not_found {
  @doc Print command not found error message and exit
  @arg _1_ the command that was not found
  local cmd=${1:?}
  log::error "cmd is either not installed or not on the PATH"
  exit 1
}

function commands::use {
  @doc Find the specified command on the PATH if available or error
  @arg _1_ the base command name to find
  local cmd=${1:?}
  # shellcheck disable=SC2154
  if [ -z "$_cmd" ]; then
    local cmd_path
    cmd_path=$(command -v "$cmd") || commands::err_not_found "$cmd"
    declare -g "_${cmd}=$cmd_path"
  fi
  local var=_${cmd}
  echo "${!var}"
  return
}
