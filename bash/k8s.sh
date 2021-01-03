#!/bin/bash

# shellcheck source=doc.sh
source "$(dirname "${BASH_SOURCE[0]}")/doc.sh"

# dirs.sh must be co-resident with this file
# shellcheck source=dirs.sh
source "$(dirname "${BASH_SOURCE[0]}")/dirs.sh"
DIR=$(dirs::of)

# shellcheck source=annotations.sh
source "$DIR/annotations.sh"

@package k8s

KUBECTL=${KUBECTL:-$(command -v kubectl)}

function k8s::exec() {
  @doc On pod "$1" in container "$2" execute the command provided
  local pod="$1"
  local container="$2"
  fn::wrapped exec::capture "$KUBECTL" exec "$pod" -c "$container" "$@"
}
function kexec() {
  @doc deprecated in favor k8s::exec
  deprecated k8s::exec "$@"
}

function k8s::log() {
  doc Get the logs for container "$2" in pod "$1"
  local pod="$1"
  local container="$2"
  fn::wrapped exec::capture "$KUBECTL" logs "$pod" -c "$container" "$@"
}
function klog() {
  @doc "deprecated in favor of k8s::log"
  deprecated k8s::log "$@"
}

function k8s::cp() {
  @doc Copy the named file from/to container "$1" to/from the specied location
  local container="$1"
  fn::wrapped exec::capture "$KUBECTL" cp -c "$container" "$@"
}
function kcp() {
  @doc deprecated in favor of k8s::cp
  deprecated k8s::cp "$@"
}
