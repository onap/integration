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
# Start all process required for executing test case

#login to the onap nexus docker repo
docker login -u docker -p docker nexus3.onap.org:10001

# Start MSB
docker run -d -p 8500:8500 --name msb_consul nexus3.onap.org:10001/onap/msb/msb_base
CONSUL_IP=`get-instance-ip.sh msb_consul`
echo CONSUL_IP=${CONSUL_IP}
docker run -d -p 10081:10081 -e CONSUL_IP=$CONSUL_IP --name msb_discovery nexus3.onap.org:10001/onap/msb/msb_discovery
DISCOVERY_IP=`get-instance-ip.sh msb_discovery`
echo DISCOVERY_IP=${DISCOVERY_IP}
docker run -d -p 80:80 -e CONSUL_IP=$CONSUL_IP -e SDCLIENT_IP=$DISCOVERY_IP --name msb_internal_apigateway nexus3.onap.org:10001/onap/msb/msb_apigateway
MSB_IP==`get-instance-ip.sh msb_internal_apigateway`
echo MSB_IP=${MSB_IP}

# start vfc-nslcm
docker run -d --name vfc-nslcm -e MSB_ADDR=${MSB_IP}:80 nexus3.onap.org:10001/onap/vfc/nslcm
NSLCM_IP=`get-instance-ip.sh vfc-nslcm`
for i in {1..10}; do
    curl -sS ${NSLCM_IP}:8403 && break
    echo sleep $i
    sleep $i
done

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IP:${MSB_IP} -v NSLCM_IP:${NSLCM_IP}"
