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

function error_exit() {
  ERROR "$*"
  exit 1
}

function syntax_exit() {
  fn::if_exists syntax "$@"
  exit 1
}

function syntax {
  options::help "$(basename "${BASH_SOURCE[4]}")"
  exit 1
}

#shellcheck disable=SC2034
LOGFILE_DISABLE=true

log_level=0
function log-level {
  ((log_level += 1))
  set-log-level "$log_level"
}

function addCliOptions {
  options::add -o h -d "prints syntax and exits" -f syntax_exit
  options::add -o v -d "set verbosity level" -f log-level
}
