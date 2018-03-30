#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
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
# Place the scripts in run order:
# Start all process required for executing test case

source ${SCRIPTS}/common_functions.sh

# start multivim-broker
docker run -d --name multivim-vio nexus3.onap.org:10001/onap/multicloud/vio
docker run -d --name multivim-broker --link multivim-vio -e MSB_ADDR=multivim-vio -e MSB_PORT=9004 nexus3.onap.org:10001/onap/multicloud/framework

BROKER_IP=`get-instance-ip.sh multivim-broker`
for i in {1..50}; do
    curl -sS ${BROKER_IP}:9001 && break
    echo sleep $i
    sleep $i
done

echo SCRIPTS
# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v BROKER_IP:${BROKER_IP}"
