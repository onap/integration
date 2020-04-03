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

set -eu

HERE=${0%/*}
source $HERE/common.sh

WORKDIR=$(mktemp -d)
trap "rm -rf $WORKDIR" EXIT

sysrepocfg --format=xml --export=$WORKDIR/load_server_certs.xml ietf-keystore
sysrepocfg --format=xml --export=$WORKDIR/tls_listen.xml ietf-netconf-server
configure_tls running import $WORKDIR

pid=$(cat /var/run/netopeer2-server.pid)
log INFO Restart Netopeer2 pid=$pid
kill $pid
