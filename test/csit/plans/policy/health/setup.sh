#!/bin/bash
#
#
# Place the scripts in run order:
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

sleep 3m

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MOCK_IP:${MOCK_IP} -v IP:${IP} -v POLICY_IP:${POLICY_IP} -v DOCKER_IP:${DOCKER_IP}" 
export POLICY_IP=${POLICY_IP}
export DOCKER_IP=${DOCKER_IP}

#Get current IP of VM
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
export HOST_IP=${HOST_IP}