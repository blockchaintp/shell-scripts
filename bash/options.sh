#!/bin/bash

OPTIONS=()
declare -A OPTIONS_DOC
declare -A OPTIONS_OPTIONAL
declare -A OPTIONS_HAS_ARGS
declare -A OPTIONS_PARSE_FUNCS
declare -A OPTIONS_ENVIRONMENT
OPTIONS_DOC=()
OPTIONS_OPTIONAL=()
OPTIONS_HAS_ARGS=()
OPTIONS_PARSE_FUNCS=()
OPTIONS_ENVIRONMENT=()

function options::clear() {
  OPTIONS=()
  OPTIONS_DOC=()
  OPTIONS_OPTIONAL=()
  OPTIONS_HAS_ARGS=()
  OPTIONS_PARSE_FUNCS=()
  OPTIONS_ENVIRONMENT=()
}

function options::add() {
  local argument="false"
  local optional="true"
  local description="no description"
  local parse_fn=""
  local environment_var=""
  while [ -n "$1" ]; do
    opt="$1"
    shift
    case "$opt" in
      -o)
        option="${1}"
        shift
        ;;
      -d)
        description="${1}"
        shift
        ;;
      -m)
        optional="false"
        ;;
      -a)
        argument="true"
        ;;
      -e)
        environment_var="${1}"
        declare -g "${environment_var}="
        shift
        ;;
      -x)
        environment_var="${1}"
        declare -g "${environment_var}=false"
        shift
        ;;
      -f)
        parse_fn="${1}"
        shift
        ;;
      *)
        return 1
        ;;
    esac
  done
  OPTARG=
  if [ -z "$option" ]; then
    echo "Invalid option specification"
    return 1
  fi

  OPTIONS+=("$option")
  OPTIONS_DOC[$option]="$description"
  OPTIONS_OPTIONAL[$option]="$optional"
  OPTIONS_HAS_ARGS[$option]="$argument"
  [ -n "$parse_fn" ] && OPTIONS_PARSE_FUNCS[$option]="$parse_fn"
  [ -n "$environment_var" ] && OPTIONS_ENVIRONMENT[$option]="$environment_var"
}

function options::spec() {
  local spec=""
  for opt in "${OPTIONS[@]}"; do
    spec="${spec}${opt}"
    if [ "${OPTIONS_HAS_ARGS[$opt]}" = "true" ]; then
      spec="${spec}:"
    fi
  done
  echo "$spec"
}

function options::syntax() {
  local command=$1
  local spec=""
  items=()
  for opt in "${OPTIONS[@]}"; do
    item="-${opt}"
    if [ "${OPTIONS_HAS_ARGS[$opt]}" = "true" ]; then
      item="$item <arg>"
    fi
    if [ "${OPTIONS_OPTIONAL[$opt]}" = "true" ]; then
      item="[$item]"
    fi
    items+=("$item")
  done
  printf "%s\n" "SYNTAX"
  printf "\t%s %s\n" "$command" "${items[*]}"

}

function options::doc() {
  local command="$1"
  count=0
  printf "%s\n" "OPTIONS"
  for opt in "${OPTIONS[@]}"; do
    local description="${OPTIONS_DOC[$opt]}"
    if [ "${OPTIONS_OPTIONAL[$opt]}" = "true" ]; then
      mandatory=""
    else
      mandatory=" (required)"
    fi
    if [ "${OPTIONS_HAS_ARGS[$opt]}" = "false" ]; then
      args=""
    else
      args="<arg>"
    fi
    printf "\t-%s %-5s  %-40s\n" "$opt" "$args" "$mandatory $description"
    ((count += 1))
  done
}

function options::help() {
  local cmd
  if [ -z "$1" ]; then
    cmd="${BASH_SOURCE[1]}"
  else
    cmd="$1"
  fi
  options::syntax "$(basename "${cmd}")"
  options::doc "$(basename "${cmd}")"
}

function options::getopts() {
  getopts "$(options::spec)" "$@"
}

function options::parse() {
  while options::getopts opt "$@"; do
    if [ "$opt" != "?" ]; then
      if [ -n "${OPTIONS_ENVIRONMENT[$opt]}" ]; then
        local varName="${OPTIONS_ENVIRONMENT[$opt]}"
        local val
        if [ -n "${OPTARG}" ]; then
          val="${OPTARG}"
        else
          val="true"
        fi
        declare -g "$varName=${val}"
      elif [ -n "${OPTIONS_PARSE_FUNCS[$opt]}" ]; then
        if command -v "${OPTIONS_PARSE_FUNCS[$opt]}" >/dev/null; then
          ${OPTIONS_PARSE_FUNCS[$opt]} "${OPTARG}"
        else
          echo "ERROR: parse_functions must be defined or left out"
          exit 1
        fi
      fi
    else
      return 1
    fi
  done
}
