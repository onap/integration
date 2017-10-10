#!/bin/bash
#
# Copyright 2017 AT&T Intellectual Property. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

function kill_instance() {
local name=$1
docker logs "${name}" >> "${WORKSPACE}"/archives/"${name}".log
docker kill "${name}"
docker rm -v "${name}"
}

mkdir -p "${WORKSPACE}"/archives

kill_instance i-mock
kill_instance drools
kill_instance pdp
kill_instance brmsgw
kill_instance pap
kill_instance nexus
kill_instance mariadb

rm -fr "${WORK_DIR}"

