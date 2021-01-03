#!/bin/bash

# dirs.sh must be co-resident with this file
# shellcheck source=dirs.sh
source "$(dirname "${BASH_SOURCE[0]}")/dirs.sh"
DIR=$(dirs::of)

# shellcheck source=annotations.sh
source "$DIR/annotations.sh"

KUBECTL=${KUBECTL:-$(command -v kubectl)}

function k8s::exec() {
  local pod="$1"
  local container="$2"
  fn::wrapped exec::capture "$KUBECTL" exec "$pod" -c "$container" "$@"
}
function kexec() {
  deprecated k82::exec "$@"
}

function k8s::log() {
  local pod="$1"
  local container="$2"
  fn::wrapped exec::capture "$KUBECTL" logs "$pod" -c "$container" "$@"
}
function klog() {
  deprecated k8s::log "$@"
}

function k8s::cp() {
  local container="$1"
  fn::wrapped exec::capture "$KUBECTL" cp -c "$container" "$@"
}
function kcp() {
  deprecated k8s::cp "$@"
}
