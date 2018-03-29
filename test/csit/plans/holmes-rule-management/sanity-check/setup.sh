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

# Download and start MySQL
docker pull postgres:9.5
docker run --name postgres-holmes -p 5432:5432 -e POSTGRES_USER=holmes -e POSTGRES_PASSWORD=holmespwd -d postgres:9.5 
DB_IP=`get-instance-ip.sh postgres-holmes`
echo DB_IP=${DB_IP}

#login to the onap nexus docker repo
docker login -u docker -p docker nexus3.onap.org:10001

# Start MSB
docker run -d -p 8500:8500 --name msb_consul consul:0.9.3
CONSUL_IP=`get-instance-ip.sh msb_consul`
echo CONSUL_IP=${CONSUL_IP}
docker run -d -p 10081:10081 -e CONSUL_IP=$CONSUL_IP --name msb_discovery nexus3.onap.org:10001/onap/msb/msb_discovery
DISCOVERY_IP=`get-instance-ip.sh msb_discovery`
echo DISCOVERY_IP=${DISCOVERY_IP}
docker run -d -p 80:80 -e CONSUL_IP=$CONSUL_IP -e SDCLIENT_IP=$DISCOVERY_IP --name msb_internal_apigateway nexus3.onap.org:10001/onap/msb/msb_apigateway
MSB_IP=`get-instance-ip.sh msb_internal_apigateway`
echo MSB_IP=${MSB_IP}

# Start rulemgt
source ${SCRIPTS}/holmes/rule-management/startup.sh i-rulemgt ${DB_IP} ${MSB_IP} 1
RULEMGT_IP=`get-instance-ip.sh i-rulemgt`
echo RULEMGT_IP=${RULEMGT_IP}

# Wait for initialization
for i in {1..20}; do
    curl -sS -m 1 ${RULEMGT_IP}:9101 && curl -sS -m 1 ${MSB_IP}:80 && break
    echo sleep $i
    sleep $i
done

# Start engine-d
source ${SCRIPTS}/holmes/engine-management/startup.sh i-engine-d ${DB_IP} ${MSB_IP} 1
ENGINE_D_IP=`get-instance-ip.sh i-engine-d`
echo ENGINE_D_IP=${ENGINE_D_IP}


# Wait for initialization
for i in {1..10}; do
    curl -sS -m 1 ${ENGINE_D_IP}:9102 && break
    echo sleep $i
    sleep $i
done

echo sleep 30s for service registration...
sleep 30
 
#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IP:${MSB_IP} -v RULEMGT_IP:${RULEMGT_IP} -v ENGINE_D_IP:${ENGINE_D_IP}"

