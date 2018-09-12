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
source ${SCRIPTS}/common_functions.sh

docker run --name i-mock -d jamesdbloom/mockserver
MOCK_IP=`get-instance-ip.sh i-mock`
echo ${MOCK_IP}

docker inspect i-mock

# Wait for initialization
for i in {1..10}; do
    curl -sS ${MOCK_IP}:1080 && break
    echo sleep $i
    sleep $i
done

${WORKSPACE}/test/csit/scripts/policy/mock-hello.sh ${MOCK_IP}

source ${WORKSPACE}/test/csit/scripts/policy/script1.sh

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MOCK_IP:${MOCK_IP} -v IP:${IP} -v POLICY_IP:${POLICY_IP} -v PDP_IP:${PDP_IP} -v DOCKER_IP:${DOCKER_IP}" 
export PDP_IP=${PDP_IP}
export POLICY_IP=${POLICY_IP}
export DOCKER_IP=${DOCKER_IP}

#Get current IP of VM
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
export HOST_IP=${HOST_IP}
