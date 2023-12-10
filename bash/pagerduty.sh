#!/usr/bin/env bash
# Copyright © 2023 Kevin T. O'Donnell
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
@include log

@package pagerduty

function _curl() {
  $(commands::use curl) "$@"
}

function send_incident() {
  local service_id="${1:?}"
  local alert_type="${2:?}"
  local alert_title="${3:?}"
  local alert_from="${4:?}"
  local alert_token="${5:?}"
  local incident_key="${6}"

  if [ -z "$incident_key" ]; then
    incident_data() {
      cat <<EOF
        { "incident": { "type": "$alert_type", "title": "$alert_title", "service": { "id": "$service_id", "type": "service_reference" } } }
EOF
    }
  else
    incident_data() {
      cat <<EOF
        { "incident": { "type": "$alert_type", "title": "$alert_title", "service": { "id": "$service_id", "type": "service_reference" }, "incident_key": "$incident_key" } }
EOF
    }
  fi

  _curl POST --header 'Content-Type: application/json' \
    --header 'Accept: application/vnd.pagerduty+json;version=2' \
    --header "From: $alert_from" \
    --header "Authorization: Token token=$alert_token" \
    --data "$(incident_data)" 'https://api.pagerduty.com/incidents'
  log::info "Sent PagerDuty incident"
}

function send_event() {
  #set -x
  #_curl -X POST --header 'Content-Type: application/json' \
  #--header 'Accept: application/vnd.pagerduty+json;version=2' \
  #--header "From: $ALERT_FROM" \
  #--header "Authorization: Token token=$ALERT_TOKEN" \
  #--data "$(cat $PG_DATA)" 'https://api.pagerduty.com/incidents'
  log::info "Sent PagerDuty event"
}
