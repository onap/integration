#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
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
# Modifications copyright (c) 2017 AT&T Intellectual Property
#
# Place the scripts in run order:
SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${WORKSPACE}/test/csit/scripts/appc/script1.sh

export APPC_DOCKER_IMAGE_VERSION=1.3.0
export CCSDK_DOCKER_IMAGE_VERSION=0.2.4
export BRANCH=beijing
export SOLUTION_NAME=onap

export NEXUS_USERNAME=docker
export NEXUS_PASSWD=docker
export NEXUS_DOCKER_REPO=nexus3.onap.org:10001
export DMAAP_TOPIC=AUTO

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

if [ "$MTU" == "" ]; then
	  export MTU="1450"
fi


# Clone APPC repo to get docker-compose for APPC
mkdir -p $WORKSPACE/archives/appc
cd $WORKSPACE/archives
git clone -b $BRANCH --single-branch http://gerrit.onap.org/r/appc/deployment.git appc
cd $WORKSPACE/archives/appc
git pull
cd $WORKSPACE/archives/appc/docker-compose
sed -i "s/DMAAP_TOPIC_ENV=.*/DMAAP_TOPIC_ENV="$DMAAP_TOPIC"/g" docker-compose.yml
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO
docker pull $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/appc-image:$APPC_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/appc-image:$APPC_DOCKER_IMAGE_VERSION ${SOLUTION_NAME}/appc-image:latest
docker pull $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION ${SOLUTION_NAME}/ccsdk-dgbuilder-image:latest
docker pull $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/appc-cdt-image:$APPC_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/appc-cdt-image:$APPC_DOCKER_IMAGE_VERSION ${SOLUTION_NAME}/appc-cdt-image:latest

# start APPC containers with docker compose and configuration from docker-compose.yml
docker-compose up -d
# WAIT 5 minutes maximum and test every 5 seconds if APPC is up using HealthCheck API
TIME_OUT=2000
INTERVAL=30
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do

startODL_status=$(docker exec appc_controller_container ps -e | grep startODL | wc -l)
waiting_bundles=$(docker exec appc_controller_container /opt/opendaylight/current/bin/client bundle:list | grep Waiting | wc -l)
run_level=$(docker exec appc_controller_container /opt/opendaylight/current/bin/client system:start-level)

  if [ "$run_level" == "Level 100" ] && [ "$startODL_status" -lt "1" ] && [ "$waiting_bundles" -lt "1" ] ; then
    echo APPC started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if APPC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
  echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi

sleep 300

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"
