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

source ${SCRIPTS}/common_functions.sh

#start msb
docker run -d -p 8500:8500  --name msb_consul consul
MSB_CONSUL_IP=`get-instance-ip.sh msb_consul`
echo MSB_CONSUL_IP=${MSB_CONSUL_IP}

docker run -d  -p 10081:10081  -e CONSUL_IP=$MSB_CONSUL_IP --name msb_discovery nexus3.onap.org:10001/onap/msb/msb_discovery
MSB_DISCOVERY_IP=`get-instance-ip.sh msb_discovery`
echo DISCOVERY_IP=${MSB_DISCOVERY_IP}

docker run -d -p 80:80 -e CONSUL_IP=$MSB_CONSUL_IP -e SDCLIENT_IP=$MSB_DISCOVERY_IP --name msb_internal_apigateway nexus3.onap.org:10001/onap/msb/msb_apigateway
MSB_IAG_IP=`get-instance-ip.sh msb_internal_apigateway`
echo MSB_IAG_IP=${MSB_IAG_IP}

# Wait for initialization(8500 Consul, 10081 Service Registration & Discovery, 80 api gateway)
for i in {1..10}; do
    curl -sS -m 1 ${MSB_CONSUL_IP}:8500 && curl -sS -m 1 ${MSB_DISCOVERY_IP}:10081 && curl -sS -m 1 ${MSB_IAG_IP}:80 && break
    echo sleep $i
    sleep $i
done

# wait for container initalization
echo sleep 30
sleep 30

# start vfc-vnflcm
docker run -d --name vfc-vnflcm -v /var/lib/mysql -e MSB_ADDR=${MSB_IAG_IP}:80 nexus3.onap.org:10001/onap/vfc/vnflcm
VNFLCM_IP=`get-instance-ip.sh vfc-vnflcm`

docker logs -f vfc-vnflcm > vfc-vnflcm.log &

# Wait for initialization
for i in {1..10}; do
    curl -sS -m 1 ${VNFLCM_IP}:8801 && break
    echo sleep $i
    sleep $i
done

echo "================================================"
cat vfc-vnflcm.log

echo "================================================"
docker cp vfc-vnflcm:/service/vfc/gvnfm/vnflcm/lcm/docker/instance_init.sh ./
cat instance_init.sh

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IAG_IP:${MSB_IAG_IP} -v MSB_DISCOVERY_IP:${MSB_DISCOVERY_IP} -v VNFLCM_IP:${VNFLCM_IP}"
