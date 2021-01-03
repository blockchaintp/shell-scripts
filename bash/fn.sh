#!/bin/bash

# dirs.sh must be co-resident with this file
# shellcheck source=dirs.sh
source "$(dirname "${BASH_SOURCE[0]}")/dirs.sh"
DIR=$(dirs::of)

# shellcheck source=annotations.sh
source "$DIR/annotations.sh"

function fn::if_exists() {
  local func=$1
  shift
  local _type
  _type="$(type -t "$func")"
  if [ -n "$_type" ]; then
    $func "$@"
  fi
}
function fn_if_exists() {
  deprecated fn::if_exists "$@"
}

function fn::wrapped() {
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
  deprecated fn::wrapped "$@"
}
