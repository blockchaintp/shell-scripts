#!/usr/bin/env bash
# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include log

@package error

function error::exit {
  @doc Issue the requested error log and exit with error.
  @arg _1_ the error log message
  log::error "$*"
  exit 1
}
