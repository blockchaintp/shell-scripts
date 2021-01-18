#!/usr/bin/env bash
# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include log

function error::exit {
  log::error "$*"
  exit 1
}
