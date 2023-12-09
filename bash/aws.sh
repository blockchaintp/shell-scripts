#!/usr/bin/env bash
# Copyright © 2023 Paravela Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------------

# shellcheck source=includer.sh
source "$(dirname "${BASH_SOURCE[0]}")/includer.sh"

@include commands

@package aws

function aws::cmd {
  $(commands::use aws) --output json "$@"
}

function _jq {
  $(commands::use jq) "$@"
}

function aws::ecr {
  aws::cmd ecr "$@"
}

function aws::get_repositories {
  aws::ecr describe-repositories | _jq -r '.repositories[].repositoryName' |
    sort
}

function aws::get_tags {
  local repository=${1:?}
  aws::ecr list-images "--repository-name=$repository" |
    _jq -r '.imageIds[].imageTag' | sort
}

function aws::scan {
  local tag=$1
  for repository in $(aws::get_repositories); do
    if [ "$repository" = "blockchaintp/busybox" ]; then
      log::info "Skipping busybox repository"
      continue
    fi
    log::info "Scanning $repository $tag"
    aws::scan_repository "$repository" "$tag"
  done
}

function aws::scan_repository {
  local repository=${1:?}
  local set_tag=$2
  if [ -z "$set_tag" ]; then
    for tag in $(aws::get_tags "$repository"); do
      aws::refresh_scan "$repository" "$tag"
    done
  else
    if aws::get_tags "$repository" | grep -q "^$set_tag$"; then
      aws::refresh_scan "$repository" "$set_tag"
    fi
  fi
}

function aws::scan_image {
  local repository=${1:?}
  local tag=${2:?}
  local status
  status=$(aws::scan_status "$repository" "$tag")
  if [ "$status" = "IN_PROGRESS" ]; then
    log::info "Scan of $repository:$tag is already in progress"
    return 0
  elif [ "$status" = "FAILED" ]; then
    local description
    description=$(_describe_findings "$repository" "$tag" |
      _jq -r '.imageScanStatus.description')
    log::warn "Scan of $repository:$tag $description"
    return 1
  fi
  log::info "Scanning of $repository:$tag"
  status=$(aws::ecr start-image-scan "--repository-name=$repository" \
    --image-id imageTag="$tag" |
    _jq -r '.imageScanStatus.status')
  log::info "Scan of $repository:$tag is now $status"
}

function _describe_findings {
  local repository=${1:?}
  local tag=${2:?}
  local status
  aws::ecr describe-image-scan-findings "--repository-name=$repository" \
    --image-id imageTag="$tag" 2>/dev/null
}

function aws::scan_status {
  local repository=${1:?}
  local tag=${2:?}
  local status
  _describe_findings "$repository" "$tag" |
    _jq -r '.imageScanStatus.status'
}

function aws::is_scan_complete {
  local repository=${1:?}
  local tag=${2:?}
  local status
  status=$(aws::scan_status "$repository" "$tag")
  if [ "$status" = "COMPLETE" ]; then
    return 0
  else
    return 1
  fi
}

function aws::wait_for_scan_complete {
  local repository=${1:?}
  local tag=${2:?}
  local wait_time=${3:-10}
  while ! aws::is_scan_complete "$repository" "$tag"; do
    sleep "$wait_time"
  done
}

function aws::list_findings {
  local repository=${1:?}
  local tag=${2:?}
  _describe_findings "$repository" "$tag" |
    jq -r '.imageScanFindings.findings[] |
      (.severity + " " + .name + " " + .uri)'
}

function aws::refresh_scan {
  local repository=${1:?}
  local tag=${2:?}
  local days_ago=${3:-7}
  local seconds_ago
  seconds_ago=$((days_ago * 86400))
  local now
  now=$(date +%s)
  local earliest
  earliest=$((now - seconds_ago))
  if aws::is_scan_complete "$repository" "$tag"; then
    local completedAt
    completedAt=$(_describe_findings "$repository" "$tag" |
      _jq '.imageScanFindings.imageScanCompletedAt')
    if [ $earliest -lt "$completedAt" ]; then
      log::info "Scan of $repository:$tag was done within $days_ago days"
      return
    else
      log::info "Scan of $repository:$tag was done more than $days_ago days ago"
    fi
  fi
  aws::scan_image "$repository" "$tag"
}
