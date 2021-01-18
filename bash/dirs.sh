#!/usr/bin/env bash
# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include doc
@include log
@include error

@package dirs

function dirs::of() {
  @doc Return the directory of the calling script
  index=1
  local SOURCE="${BASH_SOURCE[$index]}"
  local DIR
  while [ -h "$SOURCE" ]; do
    # resolve $SOURCE until the file is no longer a symlink
    DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  echo "$DIR"
}

function dirs::safe_rmrf {
  @doc an rm -rf command that refuses to delete certain paths
  for path in "$@"; do
    case $path in
      /)
        log::warn "Attempt to delete $path is forbidden"
        return 1
        ;;
      *)
        log::trace "$path passes safe_rmrf check"
        ;;
    esac
  done
  for path in "$@"; do
    log::trace "removing $path"
    if [ -r "$path" ]; then
      if ! rm -rf "$path"; then
        log::debug "failed to remove $path"
        return 1
      fi
    else
      log::trace "$path is already gone"
    fi
  done
  return 0
}

function dirs::replace {
  local directory=${1:?}
  log::notice "This command will replace the contents of ${1}"
  if [ -d "$directory" ]; then
    if ! dirs::safe_rmrf "$directory"; then
      error::exit "Failed to remove $directory"
    fi
  fi
  dirs::ensure "$directory"

}

function dirs::noreplace {
  @doc returns an error if the directory exists and is not empty, otherwise ensure that it exists
  local directory=${1:?}
  log::notice "This command will replace the contents ${1}"
}

function dirs::ensure {
  local directory=${1:?}
  mkdir -p "${directory}" ||
    error::exit "Failed to create ${directory}"
}
