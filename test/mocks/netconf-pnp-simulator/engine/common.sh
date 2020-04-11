#!/bin/ash
# shellcheck disable=SC2086

# ============LICENSE_START=======================================================
#  Copyright (C) 2020 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

set -o errexit
set -o pipefail
set -o nounset
[ "${SHELL_XTRACE:-false}" = "true" ] && set -o xtrace

export PATH=/opt/bin:/usr/local/bin:/usr/bin:/bin

CONFIG=/config
TEMPLATES=/templates

PROC_NAME=${0##*/}
PROC_NAME=${PROC_NAME%.sh}

WORKDIR=$(mktemp -d)
trap "rm -rf $WORKDIR" EXIT

function now_ms() {
    # Requires coreutils package
    date +"%Y-%m-%d %H:%M:%S.%3N"
}

function log() {
    local level=$1
    shift
    local message="$*"
    >&2 printf "%s %-5s [%s] %s\n" "$(now_ms)" $level $PROC_NAME "$message"
}

find_file() {
  local dir=$1
  shift
  for app in "$@"; do
    if [ -f $dir/$app ]; then
      echo -n $dir/$app
      break
    fi
  done
}


# Extracts the body of a PEM file by removing the dashed header and footer
alias pem_body='grep -Fv -- -----'


kill_service() {
    local service=$1

    pid=$(cat /var/run/${service}.pid)
    log INFO Killing $service pid=$pid
    kill $pid
}

# ------------------------------------
# SSH Common Definitions and Functions
# ------------------------------------

SSH_CONFIG=$CONFIG/ssh

configure_ssh() {
    local datastore=$1
    local operation=$2
    local dir=$3

    log INFO Configure SSH ingress service
    ssh_pubkey=$(find_file $SSH_CONFIG id_ecdsa.pub id_dsa.pub id_rsa.pub)
    test -n "$ssh_pubkey"
    name=${ssh_pubkey##*/}
    name=${name%%.pub}
    set -- $(cat $ssh_pubkey)
    xmlstarlet ed --pf --omit-decl \
        --update '//_:name[text()="netconf"]/following-sibling::_:authorized-key/_:name' --value "$name" \
        --update '//_:name[text()="netconf"]/following-sibling::_:authorized-key/_:algorithm' --value "$1" \
        --update '//_:name[text()="netconf"]/following-sibling::_:authorized-key/_:key-data' --value "$2" \
        $dir/ietf-system.xml | \
    sysrepocfg --datastore=$datastore --permanent --format=xml ietf-system --${operation}=-
}


# ------------------------------------
# SSL Common Definitions and Functions
# ------------------------------------

TLS_CONFIG=$CONFIG/tls
KEY_PATH=/opt/etc/keystored/keys

configure_tls() {
    local datastore=$1
    local operation=$2
    local dir=$3

    log INFO Update server private key
    cp $TLS_CONFIG/server_key.pem $KEY_PATH

    log INFO Load CA and server certificates
    ca_cert=$(pem_body $TLS_CONFIG/ca.pem)
    server_cert=$(pem_body $TLS_CONFIG/server_cert.pem)
    xmlstarlet ed --pf --omit-decl \
        --update '//_:name[text()="server_cert"]/following-sibling::_:certificate' --value "$server_cert" \
        --update '//_:name[text()="ca"]/following-sibling::_:certificate' --value "$ca_cert" \
        $dir/ietf-keystore.xml | \
    sysrepocfg --datastore=$datastore --permanent --format=xml ietf-keystore --${operation}=-

    log INFO Configure TLS ingress service
    ca_fingerprint=$(openssl x509 -noout -fingerprint -in $TLS_CONFIG/ca.pem | cut -d= -f2)
    xmlstarlet ed --pf --omit-decl \
        --update '//_:name[text()="netconf"]/preceding-sibling::_:fingerprint' --value "02:$ca_fingerprint" \
        $dir/ietf-netconf-server.xml | \
    sysrepocfg --datastore=$datastore --permanent --format=xml ietf-netconf-server --${operation}=-
}
