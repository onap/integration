#!/bin/bash

source ${SCRIPTS}/common_functions.sh

# start generic simulator for openstack mock and AAI mock
${WORKSPACE}/test/csit/scripts/multicloud-ocata/generic_sim/generic_sim_build.sh ${WORKSPACE}/test/csit/scripts/multicloud-ocata/generic_sim/
${WORKSPACE}/test/csit/scripts/multicloud-ocata/generic_sim/generic_sim_run.sh

GEN_SIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' generic_sim`
GEN_SIM_PORT=":8081"

# start multicloud-ocata
docker run -d -t -e MSB_ADDR=$GEN_SIM_IP -e MSB_PORT=$GEN_SIM_PORT -e AAI_ADDR=$GEN_SIM_IP \
    -p 9006:9006 --name multicloud-ocata nexus3.onap.org:10001/onap/multicloud/openstack-ocata
SERVICE_IP=`get-instance-ip.sh multicloud-ocata`
SERVICE_PORT=9006

for i in {1..50}; do
    curl -sS ${SERVICE_IP}:${SERVICE_PORT} && break
    echo sleep $i
    sleep $i
done

echo SCRIPTS
# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES+="-v SERVICE_IP:${SERVICE_IP} "
ROBOT_VARIABLES+="-v SERVICE_PORT:${SERVICE_PORT} "
