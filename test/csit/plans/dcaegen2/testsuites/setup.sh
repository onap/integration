#!/bin/bash
#
# Copyright 2017 ZTE Corporation.
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
#Make sure python-uuid is installed


#get current host IP addres
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')

VESC_IMAGE=nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.ves.vescollector:1.1
echo VESC_IMAGE=${VESC_IMAGE}

# Start DCAE VES Collector
docker run -d -p 8080:8080/tcp -p 8443:8443/tcp -P --name vesc -e DMAAPHOST=${HOST_IP} ${VESC_IMAGE}

VESC_IP=`get-instance-ip.sh vesc`
export VESC_IP=${VESC_IP}
export HOST_IP=${HOST_IP}

export ROBOT_VARIABLES="--pythonpath ${WORKSPACE}/test/csit/tests/dcaegen2/testcases/resources"

pip install jsonschema uuid
# Wait container ready
sleep 5

