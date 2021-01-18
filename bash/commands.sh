#!/usr/bin/env bash
# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include doc
@include log

@package command

function commands::err_not_found {
  local cmd=${1:?}
  log::error "cmd is either not installed or not on the PATH"
  exit 1
}

function commands::use {
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
