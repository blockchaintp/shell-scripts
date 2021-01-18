#!/usr/bin/env bash
# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"

@package includer

function @include {
  local include_file=${1:?}
  local true_file
  true_file="$(dirname "${BASH_SOURCE[0]}")/$include_file"
  [ ! -r "$true_file" ] && true_file="$true_file.sh"
  if [ -r "$true_file" ]; then
    local file_cksum
    file_cksum=$(cksum "$true_file" | awk '{print $1}')
    local src_name=include_${file_cksum}
    if [ -z "${!src_name}" ]; then
      declare -g "$src_name=${src_name}"
      # shellcheck disable=SC1090
      source "$true_file"
    fi
  else
    echo "Cannot find include file $true_file"
    exit 1
  fi
}

function includer::find {
  @doc Find the file referred to as an include.
  @arg _1_ the name of the include
  local include_file=${1:?}
  local true_file
  true_file="$(dirname "${BASH_SOURCE[0]}")/$include_file"
  [ ! -r "$true_file" ] && true_file="$true_file.sh"
  if [ -r "$true_file" ]; then
    echo "$true_file"
  else
    return 1
  fi
}
