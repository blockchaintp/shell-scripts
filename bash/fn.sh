#!/usr/bin/env bash

src_name=include_$(sha256sum "${BASH_SOURCE[0]}" | awk '{print $1}')
if [ -z "${!src_name}" ]; then
  declare -g "$src_name=${src_name}"
else
  return
fi

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"

# dirs.sh must be co-resident with this file
# shellcheck source=dirs.sh
source "$(dirname "${BASH_SOURCE[0]}")/dirs.sh"
DIR=$(dirs::of)

# shellcheck source=annotations.sh
source "$DIR/annotations.sh"

@package fn

function fn::if_exists() {
  @doc if the named function exists with the specified argument execute it \
    otherwise return
  local func=$1
  shift
  local _type
  _type="$(type -t "$func")"
  if [ -n "$_type" ]; then
    $func "$@"
  fi
}
function fn_if_exists() {
  @doc "Deprecated in favor of fn::if_exists"
  deprecated fn::if_exists "$@"
}

function fn::wrapped() {
  @doc Call/wrap the named function. The wrapper is expected to execute the \
    the wrapped function
  local wrapper=$1
  shift
  local _type
  _type="$(type -t "$wrapper")"
  if [ -n "$_type" ]; then
    $wrapper "$@"
  else
    "$@"
  fi
}
function fn_wrapped() {
  @doc Deprecated in favor of fn::wrapped
  deprecated fn::wrapped "$@"
}
