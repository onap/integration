#!/bin/bash
#
# Copyright 2018 Intel Corporation, Inc
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

cd ${SCRIPTS}

source common_functions.sh

nova_port=8774
aai_port=30233

generic_sim_path=${WORKSPACE}/test/csit/scripts/multicloud-ocata/generic_sim
multicloud_provision_path=${WORKSPACE}/test/csit/tests/multicloud-ocata/provision
# start generic simulator for openstack mock and AAI mock
if [[ -z $(docker images -q generic_sim) ]]; then
    pushd $generic_sim_path
    docker build -t generic_sim .
    popd
fi

function start_simulator ()
{
    local service_name=$1
    local service_port=$2

    docker run -d -v ${multicloud_provision_path}/${service_name}/:/tmp/generic_sim/ \
                  -v ${generic_sim_path}/${service_name}/:/etc/generic_sim \
                  -p $service_port:8080 --name $service_name generic_sim
    # ./run-instance.sh generic_sim $service_name "-v ${multicloud_provision_path}/${service_name}/:/tmp/generic_sim/ -v ${generic_sim_path}/${service_name}/:/opt/generic_sim/ -p $service_port:8080"
    ip_address=$(./get-instance-ip.sh $service_name)
    bypass_ip_adress $ip_address
    export $service_name"_ip"=$ip_address
}

start_simulator nova $nova_port
start_simulator aai $aai_port

# start multicloud-ocata
./run-instance.sh nexus3.onap.org:10001/onap/multicloud/openstack-ocata multicloud-ocata "-t -e MSB_ADDR=$nova_ip -e MSB_PORT=$nova_port -e AAI_ADDR=$aai_ip -p 9006:9006"
SERVICE_IP=$(./get-instance-ip.sh multicloud-ocata)
SERVICE_PORT=9006

bypass_ip_adress $SERVICE_IP
wait_for_service_init ${SERVICE_IP}:${SERVICE_PORT} 50

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES+="-v SERVICE_IP:${SERVICE_IP} "
ROBOT_VARIABLES+="-v SERVICE_PORT:${SERVICE_PORT} "
