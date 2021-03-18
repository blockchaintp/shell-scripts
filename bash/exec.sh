#!/usr/bin/env bash
# Copyright 2021 Blockchain Technology Partners
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------------

# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include annotations
@include doc

@package exec

function exec::capture() {
  @doc Execute the provided command and capture the output to a log.
  @arg _1_ the command to execute
  @arg @ the arguments to the command
  if [ -z "$LOGFILE_DISABLE" ] || [ "$LOGFILE_DISABLE" != "true" ]; then
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
