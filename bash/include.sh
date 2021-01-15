#!/bin/bash

# dirs.sh must be co-resident with this file
# shellcheck source=dirs.sh
source "$(dirname "${BASH_SOURCE[0]}")/dirs.sh"
DIR=$(dirs::of)

COMMAND_NAME="$(basename "$0")"
# shellcheck disable=SC2034
COMPONENT_NAME="$COMMAND_NAME"

# shellcheck source=annotations.sh
source "$DIR/annotations.sh"

# shellcheck source=bash-logger.sh
source "$DIR/bash-logger.sh"

# shellcheck source=exec.sh
source "$DIR/exec.sh"

# shellcheck source=k8s.sh
source "$DIR/k8s.sh"

#shellcheck source=fn.sh
source "$DIR/fn.sh"

#shellcheck source=options.sh
source "$DIR/options.sh"

#shellcheck source=git.sh
source "$DIR/git.sh"

#shellcheck source=docker.sh
source "$DIR/docker.sh"

function error_exit() {
  log::error "$*"
  exit 1
}

#shellcheck disable=SC2034
LOGFILE_DISABLE=true

log_level=0
function log-level() {
  ((log_level += 1))
  log::level "$log_level"
}

function addCliOptions() {
  options::add -o v -d "set verbosity level" -f log-level
}
