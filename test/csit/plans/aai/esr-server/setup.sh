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
MSB_IP=`get-instance-ip.sh msb_internal_apigateway`
echo MSB_IP=${MSB_IP}

# Start esr-server
#docker run -d --name esr-server --env msbDiscoveryIp=${DISCOVERY_IP} --env msbDiscoveryPort=10081 nexus3.onap.org:10001/onap/aai/esr-server
#sudo docker run -e MSB_ADDR=${MSB_IP}:80 nexus3.onap.org:10001/onap/aai/esr-server -p  9518:9518 -d --net=host --name esr-server
docker run -d --name esr-server -e MSB_ADDR=${MSB_IP}:80 nexus3.onap.org:10001/onap/aai/esr-server
#source ${SCRIPTS}/aai/esr-server/startup.sh i-esrserver ${MSB_IP} 80
ESRSERVER_IP=`get-instance-ip.sh esr-server`
echo ESRSERVER_IP=${ESRSERVER_IP}

# Wait for initialization
for i in {1..20}; do
    curl -sS -m 1 ${ESRSERVER_IP}:9518 && curl -sS -m 1 ${MSB_IP}:80 && break
    echo sleep $i
    sleep $i
done

# Wait for initialization
for i in {1..20}; do
    HTTP_CODE=`curl -o /dev/null -s -w "%{http_code}" "${MSB_IP}:80/api/aai-esr-server/v1/test"`
    if [ ${HTTP_CODE} -eq 200 ]; then
       break;
    else
       sleep $i
    fi
done

curl -X POST -H "Content-Type: application/json" -d '{"serviceName": "aai-esr-server", "version": "v1", "url": "/api/aai-esr-server/v1","protocol": "REST", "enable_ssl":"true",  "visualRange":"1", "nodes": [ {"ip": "'${ESRSERVER_IP}'","port": "9518"}]}' "http://${MSB_IP}:10081/api/microservices/v1/services"

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IP:${MSB_IP} -v ESRSERVER_IP:${ESRSERVER_IP}"



