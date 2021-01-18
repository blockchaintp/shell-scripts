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

@include doc
@include error
@include exec

@package secret

declare -g -A SECRETS
declare -g -A SECRETS_FILES

function secret::register_env {
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
  local secretName=${1:?}
  if ! secret::exists "$secretName"; then
    error::exit "No such secret $secretName"
  fi
}

function secret::as_file {
  local secretName=${1:?}
  secret::must_exist "$secretName"
  case "${SECRETS[$secretName]}" in
    environment)
      secret::env_as_file "$secretName"
      ;;
    file)
      secret::file_as_file "$secretName"
      ;;
    *)
      return 1
      ;;
  esac
}

function secret::file_as_file {
  local secretName=${1:?}
  printf "%s" "${SECRETS_FILES[$secretName]}"
}

function secret::env_as_file {
  local secretName=${1:?}
  local tmpFile
  tmpFile=$(mktemp)
  (printenv "$secretName") >"$tmpFile"
  echo "$tmpFile"
}
