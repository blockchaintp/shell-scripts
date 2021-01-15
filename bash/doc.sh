#!/bin/bash

src_name=include_$(sha256sum "${BASH_SOURCE[0]}" | awk '{print $1}')
if [ -z "${!src_name}" ]; then
  declare -g "$src_name=${src_name}"
else
  return
fi

# This function does nothing and is only in aid of script documentation
# It is used mark text in lieu of comments to document a function.
function @doc() {
  return 0
}

# This function does nothing and is only in aid of script documentation
# It is used mark an argument
function @arg() {
  return 0
}

# Used to annotate the "package" that a given include file is a part of
function @package() {
  return 0
}
