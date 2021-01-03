#!/bin/bash

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"

@package options

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
  @doc Clear the current options configuration
  OPTIONS=()
  OPTIONS_DOC=()
  OPTIONS_OPTIONAL=()
  OPTIONS_HAS_ARGS=()
  OPTIONS_PARSE_FUNCS=()
  OPTIONS_ENVIRONMENT=()
}

function options::add() {
  @doc add an option to the current configuration
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
        @arg -o "<arg>" the option to add
        option="${1}"
        shift
        ;;
      -d)
        @arg -d "<arg>" the description of the option
        description="${1}"
        shift
        ;;
      -m)
        @arg -m the option is mandatory
        optional="false"
        ;;
      -a)
        @arg -a the option has an argument
        argument="true"
        ;;
      -e)
        @arg -a "<arg>" the option will set the named global environment var \
          with its argument
        environment_var="${1}"
        declare -g "${environment_var}="
        shift
        ;;
      -x)
        @arg -x "<arg>" the option will set the named global environment var \
          as a flag
        environment_var="${1}"
        declare -g "${environment_var}=false"
        shift
        ;;
      -f)
        @arg -f "<arg>" the option will call the named function with its argument
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
  @doc echo the getopt spec defined by the options
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
  @doc echo the syntax of these options for as if used by command specified
  @arg $1 the command specified
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
  @doc print the documentation for the options
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
  @doc print the full help for these options either for the calling script \
    or for the specified command
  @arg $1 optionally specify the command name
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
  @doc run getops for the options specification
  getopts "$(options::spec)" "$@"
}

function options::parse() {
  @doc parse the options using the provided argument array
  @arg "$@" the provided argument array
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
