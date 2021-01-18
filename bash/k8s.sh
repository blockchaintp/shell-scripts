#!/usr/bin/env bash
# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include annotations
@include commands
@include doc
@include fn
@include log

@package k8s

function k8s::ctl() {
  @doc Smart commnad kubectl
  log::trace "fn::wrapped exec::capture $(commands::use kubectl) $*"
  fn::wrapped exec::capture "$(commands::use kubectl)" "$@"
}

function k8s::exec() {
  @doc On pod "$1" in container "$2" execute the command provided
  local pod="${1:?}"
  local container="${2:?}"
  shift 2
  k8s::ctl exec "$pod" -c "$container" "$@"
}
function kexec() {
  @doc deprecated in favor k8s::exec
  deprecated k8s::exec "$@"
}

function k8s::log() {
  @doc Get the logs
  k8s::ctl logs "$@"
}
function klog() {
  @doc "deprecated in favor of k8s::log"
  deprecated k8s::log "$@"
}

function k8s::cp() {
  @doc Copy the named file to/from a k8s pod/container
  k8s::ctl cp "$@"
}
function kcp() {
  @doc deprecated in favor of k8s::cp
  deprecated k8s::cp "$@"
}

function k8s::get() {
  @doc get k8s resources
  k8s::ctl get "$@"
}

function k8s::get_pod_names() {
  @doc get the list of pod names
  k8s::get pods -o name "$@"
}

function k8s::get_containers_for_pod() {
  @doc get the list of container names for this pod
  local pod=${1:?}
  pod=${pod//pod\//}
  k8s::get pod "${pod}" -o json | $(commands::use jq) \
    -r '.spec.containers[].name'
}

function k8s::config() {
  @doc Smart command kubectl config
  k8s::ctl config "$@"
}

function k8s::describe() {
  @doc Smart command kubectl describe
  k8s::ctl describe "$@"
}

function k8s::current_ns() {
  @doc Get the currently selected namespace
  k8s::config view --minify --output 'jsonpath={..namespace}'
}

function k8s::current_cluster() {
  @doc Get the currently selected cluster
  k8s::config view --minify --output 'jsonpath={..context.cluster}'
}
