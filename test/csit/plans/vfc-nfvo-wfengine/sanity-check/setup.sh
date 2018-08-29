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
docker run -d -p 8500:8500  --name msb_consul consul:0.9.3
MSB_CONSUL_IP=`get-instance-ip.sh msb_consul`
echo MSB_CONSUL_IP=${MSB_CONSUL_IP}
docker run -d  -p 10081:10081  -e CONSUL_IP=$MSB_CONSUL_IP --name msb_discovery nexus3.onap.org:10001/onap/msb/msb_discovery:1.1.0
MSB_DISCOVERY_IP=`get-instance-ip.sh msb_discovery`
echo MSB_DISCOVERY_IP=${MSB_DISCOVERY_IP}
docker run -d -p 80:80 -e CONSUL_IP=$MSB_CONSUL_IP -e SDCLIENT_IP=$MSB_DISCOVERY_IP --name msb_internal_apigateway nexus3.onap.org:10001/onap/msb/msb_apigateway:1.1.0
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

ORG="onap"
PROJECT="vfc"
DOCKER_REPOSITORY="nexus3.onap.org:10001"
IMAGE="wfengine-activiti"
IMAGE_ACTIVITI_NAME="${DOCKER_REPOSITORY}/${ORG}/${PROJECT}/${IMAGE}"

#get current host IP addres
SERVICE_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')

# start wfengine-activiti
# docker run -d --name vfc_wfengine_activiti -p 8804:8080 -e SERVICE_IP=$SERVICE_IP -e SERVICE_PORT=8804 -e OPENPALETTE_MSB_IP=${MSB_IAG_IP} -e OPENPALETTE_MSB_PORT=80 ${IMAGE_ACTIVITI_NAME}
docker run -d --name vfc_wfengine_activiti -p 8804:8080 -e SERVICE_PORT=8080 -e OPENPALETTE_MSB_IP=${MSB_IAG_IP} -e OPENPALETTE_MSB_PORT=80 ${IMAGE_ACTIVITI_NAME}
WFENGINE_ACTIVITI_IP=`get-instance-ip.sh vfc_wfengine_activiti`

# Wait for initialization
for i in {1..10}; do
    curl -sS ${WFENGINE_ACTIVITI_IP}:8080 && break
    echo sleep $i
    sleep $i
done
for i in {1..10}; do
    curl -sS ${SERVICE_IP}:8804 && break
    echo sleep $i
    sleep $i
done
docker logs vfc_wfengine_activiti

IMAGE="wfengine-mgrservice"
IMAGE_MGRSERVICE_NAME="${DOCKER_REPOSITORY}/${ORG}/${PROJECT}/${IMAGE}"

# Start wfengine-mgrservice
#docker run -d --name vfc_wfengine_mgrservice -p 8805:10550 -e SERVICE_IP=$SERVICE_IP -e SERVICE_PORT=8805 -e OPENPALETTE_MSB_IP=${MSB_IAG_IP} -e OPENPALETTE_MSB_PORT=80 ${IMAGE_MGRSERVICE_NAME}
# docker run -d --name vfc_wfengine_mgrservice -p 8805:10550 -e SERVICE_PORT=10550 -e OPENPALETTE_MSB_IP=${MSB_IAG_IP} -e OPENPALETTE_MSB_PORT=80 ${IMAGE_MGRSERVICE_NAME}
docker run -d --name vfc_wfengine_mgrservice -p 8805:10550 -e SERVICE_PORT=10550 -e OPENPALETTE_MSB_IP=${OPENPALETTE_MSB_IP} -e OPENPALETTE_MSB_PORT=8080 ${IMAGE_MGRSERVICE_NAME}

##docker run -d --name ${IMAGE} -e OPENPALETTE_MSB_IP=${WFENGINEACTIVITIR_IP} -e OPENPALETTE_MSB_PORT=8080 ${IMAGE_MGRSERVICE_NAME}
WFENGINE_MGRSERVICE_IP=`get-instance-ip.sh vfc_wfengine_mgrservice`
for i in {1..10}; do
    curl -sS ${WFENGINE_MGRSERVICE_IP}:10550 && break
    echo sleep $i
    sleep $i
done
docker logs vfc_wfengine_mgrservice

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IAG_IP:${MSB_IAG_IP} -v MSB_IP:${MSB_IAG_IP} -v MSB_PORT:80 -v MSB_DISCOVERY_IP:${MSB_DISCOVERY_IP} -v ACTIVITI_IP:${WFENGINE_ACTIVITI_IP} -v ACTIVITI_PORT:8080 -v MGRSERVICE_IP:${WFENGINE_MGRSERVICE_IP} -v MGRSERVICE_PORT:10550 -v SCRIPTS:${SCRIPTS}" 
##ROBOT_VARIABLES="-v MSB_IAG_IP:${WFENGINEACTIVITIR_IP} -v MSB_IP:${WFENGINEMGRSERVICE_IP} -v MSB_PORT:10550 -v MSB_DISCOVERY_IP:${WFENGINEACTIVITIR_IP} -v MSB_DISCOVERY_PORT:8080 -v WFENGINEACTIVITIR_IP:${WFENGINEACTIVITIR_IP} -v WFENGINEACTIVITIR_PORT:8080 -v WFENGINEMGRSERVICE_IP:${WFENGINEMGRSERVICE_IP} -v WFENGINEMGRSERVICE_PORT:10550 -v SCRIPTS:${SCRIPTS}" 