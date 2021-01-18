#!/usr/bin/env bash
# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

include doc.sh
include annotations.sh

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
