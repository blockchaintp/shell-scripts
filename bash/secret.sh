#!/usr/bin/env bash
# Copyright © 2023 Kevin T. O'Donnell
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

@include doc
@include error
@include exec

@package secret

declare -g -A SECRETS
declare -g -A SECRETS_FILES
declare -g -a SECRET_TMPFILES

function secret::register_env {
  @doc Register a secret under the provided name
  @arg _1_ the secret name
  @arg _2_ optional - the name of a different env var containing the secret val
  set +x
  local varName=${1:?}
  local targetVar=$2
  if [ -z "$targetVar" ]; then
    SECRETS[$varName]="environment"
    declare -g "$varName=${!varName}"
  else
    SECRETS[$varName]="environment"
    declare -g -n "$varName=${targetVar}"
  fi
}

function secret::register_file {
  @doc Register a secret in the specified file under the provided name
  @arg _1_ the secret name
  @arg _2_ the file containing the secret
  set +x
  local varName=${1:?}
  local file=${2:?}
  SECRETS[$varName]="file"
  SECRETS_FILES[$varName]="$file"
  declare -g "$varName=$(cat "${SECRETS_FILES[$varName]}")"
}

function secret::exists {
  @doc Check if secret exists.
  @arg _1_ name of the secret
  local secretName=${1:?}
  if [ -n "${SECRETS[$secretName]}" ]; then
    case "${SECRETS[$secretName]}" in
      environment)
        if [ -n "${!secretName}" ]; then
          return 0
        else
          return 1
        fi
        ;;
      file)
        if [ -r "${SECRETS_FILES[$secretName]}" ]; then
          return 0
        else
          return 1
        fi
        ;;
      *)
        return 1
        ;;
    esac
  else
    return 1
  fi
}

function secret::must_exist {
  @doc Verify a secret exists or exit with error
  @arg _1_ name of the secret
  local secretName=${1:?}
  if ! secret::exists "$secretName"; then
    error::exit "No such secret $secretName"
  fi
}

function secret::as_file {
  @doc Render the named secret as a temporary file and return the name
  @arg _1_ name of the secret
  set +x
  local secretName=${1:?}
  secret::must_exist "$secretName"
  case "${SECRETS[$secretName]}" in
    environment)
      _env_as_file "$secretName"
      ;;
    file)
      _file_as_file "$secretName"
      ;;
    *)
      return 1
      ;;
  esac
}

function _file_as_file {
  set +x
  local secretName=${1:?}
  printf "%s" "${SECRETS_FILES[$secretName]}"
}

function _env_as_file {
  set +x
  local secretName=${1:?}
  local tmpFile
  tmpFile=$(mktemp)
  SECRET_TMPFILES+=("$tmpFile")
  (printenv "$secretName") >"$tmpFile"
  echo "$tmpFile"
}

function secret::clear {
  @doc "Clear secret temprary files."
  if [ -n "${SECRET_TMPFILES[0]}" ]; then
    rm -f "${SECRET_TMPFILES[@]}"
  fi
}
