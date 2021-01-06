#!/bin/bash

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"
@package log

#-----------------------------------------------------------------------------
# Configurables

COMPONENT_NAME="${COMPONENT_NAME:-bash-logger}"
LOGDIR="${LOGDIR:-$HOME}"
LOGFILE="${LOGFILE:-$HOME/${COMPONENT_NAME}.log}"
export LOGFILE
export LOG_FORMAT='%DATE %PID [%LEVEL] %MESSAGE'
export LOG_DATE_FORMAT='+%F %T %Z'    # Eg: 2014-09-07 21:51:57 EST
export LOG_COLOR_DEBUG="\033[0;37m"   # Gray
export LOG_COLOR_INFO="\033[0m"       # White
export LOG_COLOR_NOTICE="\033[1;32m"  # Green
export LOG_COLOR_WARNING="\033[1;33m" # Yellow
export LOG_COLOR_ERROR="\033[1;31m"   # Red
export LOG_COLOR_CRITICAL="\033[44m"  # Blue Background
export LOG_COLOR_ALERT="\033[43m"     # Yellow Background
export LOG_COLOR_EMERGENCY="\033[41m" # Red Background
export RESET_COLOR="\033[0m"

#-----------------------------------------------------------------------------
# Individual Log Functions
# These can be overwritten to provide custom behavior for different log levels
function set-log-level() {
  deprecated log::level "$@"
}
LOG_LEVEL=${LOG_LEVEL:-0}
function log::level() {
  if [ -z "$1" ]; then
    echo "${LOG_LEVEL}"
    return
  fi
  local level=${1:?}
  LOG_DISABLE_TRACE=true
  LOG_DISABLE_DEBUG=true
  LOG_DISABLE_INFO=true
  LOG_DISABLE_WARNING=true
  if ((level > 0)); then
    LOG_DISABLE_WARNING=false
  fi
  if ((level > 1)); then
    LOG_DISABLE_INFO=false
  fi
  if ((level > 2)); then
    LOG_DISABLE_DEBUG=false
  fi
  if ((level > 3)); then
    LOG_DISABLE_TRACE=false
  fi
  LOG_LEVEL=$level
}
log::level 0

TRACE() {
  deprecated log::trace "$@"
}
log::trace() {
  if [ "$LOG_DISABLE_TRACE" = "false" ]; then
    LOG_HANDLER_DEFAULT TRACE "$@"
  fi
}

DEBUG() {
  deprecated log::debug "$@"
}
log::debug() {
  if [ "$LOG_DISABLE_DEBUG" = "false" ]; then
    LOG_HANDLER_DEFAULT DEBUG "$@"
  fi
}

INFO() {
  deprecated log::info "$@"
}
log::info() {
  if [ "$LOG_DISABLE_INFO" = "false" ]; then
    LOG_HANDLER_DEFAULT INFO "$@"
  fi
}

WARNING() {
  deprecated log::warn "$@"
}
log::warn() {
  if [ "$LOG_DISABLE_WARNING" = "false" ]; then
    LOG_HANDLER_DEFAULT WARNING "$@"
  fi
}

# ERRORS indicate an event which make it impossible to continue
#   they should never be filtered
ERROR() {
  deprecated log::error "$@"
}
log::error() {
  LOG_HANDLER_DEFAULT ERROR "$@"
}

# CRITICALS indicate an event which make it impossible to continue,
#   and likely some sort of data loss/corruption
#   they should never be filtered
CRITICAL() {
  deprecated log::critical "$@"
}
log::critical() {
  LOG_HANDLER_DEFAULT CRITICAL "$@"
}

# The following are log levels which are meant to be picked up by external
# systems, or other outside actors.
# They are not to be filtered. In oder of descending importance

#EMERGENCY - issues that should be dealt with immediately
EMERGENCY() {
  deprecated log::emergency "$@"
}
log::emergency() {
  LOG_HANDLER_DEFAULT EMERGENCY "$@"
}

# ALERT - issues that should be dealt with soon
ALERT() {
  deprecated log::alert "$@"
}
log::alert() {
  LOG_HANDLER_DEFAULT ALERT "$@"
}

# NOTICE - issues that should be dealt with optionally
NOTICE() {
  deprecated log::notice "$@"
}
log::notice() {
  LOG_HANDLER_DEFAULT NOTICE "$@"
}

#--------------------------------------------------------------------------------------------------
# Helper Functions

# Outputs a log formatted using the LOG_FORMAT and DATE_FORMAT configurables
# Usage: FORMAT_LOG <log level> <log message>
# Eg: FORMAT_LOG CRITICAL "My critical log"
FORMAT_LOG() {
  local level="$1"
  local log="$2"
  local pid=$$
  local date
  date="$(date "$LOG_DATE_FORMAT")"
  local formatted_log="$LOG_FORMAT"
  formatted_log="${formatted_log/'%MESSAGE'/$log}"
  formatted_log="${formatted_log/'%LEVEL'/$level}"
  formatted_log="${formatted_log/'%PID'/$pid}"
  formatted_log="${formatted_log/'%DATE'/$date}"
  # shellcheck disable=SC2028
  echo "$formatted_log\n"
}

# Calls one of the individual log functions
# Usage: LOG <log level> <log message>
# Eg: LOG INFO "My info log"
LOG() {
  local level="$1"
  level=$(echo "$level" | awk '{ print toupper($0)}')
  local log="$2"
  local log_function_name="${!level}"
  $log_function_name "$log"
}

log() {
  deprecated log::log "$@"
}
log::log() {
  LOG "$1" "$2"
}
#--------------------------------------------------------------------------------------------------
# Log Handlers

# All log levels call this handler (by default...), so this is a great place to put any standard
# logging behavior
# Usage: LOG_HANDLER_DEFAULT <log level> <log message>
# Eg: LOG_HANDLER_DEFAULT DEBUG "My debug log"
LOG_HANDLER_DEFAULT() {
  # $1 - level
  # $2 - message
  local formatted_log
  formatted_log="$(FORMAT_LOG "$@")"
  LOG_HANDLER_COLORTERM "$1" "$formatted_log"
  if [ -z "$LOGFILE_DISABLE" ]; then
    LOG_HANDLER_LOGFILE "$1" "$formatted_log"
  fi
}

# Outputs a log to the stdout, colourised using the LOG_COLOR configurables
# Usage: LOG_HANDLER_COLORTERM <log level> <log message>
# Eg: LOG_HANDLER_COLORTERM CRITICAL "My critical log"
LOG_HANDLER_COLORTERM() {
  local level="$1"
  local log="$2"
  local color_variable="LOG_COLOR_$level"
  local color="${!color_variable}"
  log="$color$log$RESET_COLOR"
  echo -en "$log"
}

# Appends a log to the configured logfile
# Usage: LOG_HANDLER_LOGFILE <log level> <log message>
# Eg: LOG_HANDLER_LOGFILE NOTICE "My critical log"
LOG_HANDLER_LOGFILE() {
  local level="$1"
  local log="$2"
  local log_path
  log_path="$(dirname "$LOGFILE")"
  [ -d "$log_path" ] || mkdir -p "$log_path"
  local out_log="${log//\\n/}"
  echo "$out_log" >>"$LOGFILE"
}
