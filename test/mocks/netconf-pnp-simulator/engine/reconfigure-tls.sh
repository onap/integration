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

sysrepocfg --format=xml --export=$WORKDIR/ietf-keystore.xml ietf-keystore
sysrepocfg --format=xml --export=$WORKDIR/ietf-netconf-server.xml ietf-netconf-server
configure_tls running import $WORKDIR

kill_service netopeer2-server
