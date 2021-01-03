#!/bin/bash

function deprecated() {
  local newfunc=$1
  echo "${FUNCNAME[1]} is deprecated. Replace with $newfunc"
  "$@"
}
