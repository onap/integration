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
source ${WORKSPACE}/test/csit/scripts/sdnc/script1.sh

export NEXUS_USERNAME=docker
export NEXUS_PASSWD=docker
export NEXUS_DOCKER_REPO=nexus3.onap.org:10001
export DMAAP_TOPIC=AUTO
export DOCKER_IMAGE_VERSION=1.4-STAGING-latest
export CCSDK_DOCKER_IMAGE_VERSION=0.3-STAGING-latest

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

if [ "$MTU" == "" ]; then
	  export MTU="1450"
fi


# Clone SDNC repo to get docker-compose for SDNC
mkdir -p $WORKSPACE/archives/sdnc
cd $WORKSPACE/archives
git clone -b master --single-branch --depth=1 http://gerrit.onap.org/r/sdnc/oam.git sdnc
cd $WORKSPACE/archives/sdnc
git pull
unset http_proxy https_proxy
cd $WORKSPACE/archives/sdnc/installation/src/main/yaml

sed -i "s/DMAAP_TOPIC_ENV=.*/DMAAP_TOPIC_ENV="AUTO"/g" docker-compose.yml
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-image:$DOCKER_IMAGE_VERSION onap/sdnc-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-ansible-server-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-ansible-server-image:$DOCKER_IMAGE_VERSION onap/sdnc-ansible-server-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION onap/ccsdk-dgbuilder-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/admportal-sdnc-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/admportal-sdnc-image:$DOCKER_IMAGE_VERSION onap/admportal-sdnc-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-ueb-listener-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-ueb-listener-image:$DOCKER_IMAGE_VERSION onap/sdnc-ueb-listener-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-dmaap-listener-image:$DOCKER_IMAGE_VERSION

docker tag $NEXUS_DOCKER_REPO/onap/sdnc-dmaap-listener-image:$DOCKER_IMAGE_VERSION onap/sdnc-dmaap-listener-image:latest


# start SDNC containers with docker compose and configuration from docker-compose.yml
docker-compose up -d

# WAIT 10 minutes maximum and test every 5 seconds if SDNC is up using HealthCheck API
TIME_OUT=1000
INTERVAL=30
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==" -X POST -H "X-FromAppId: csit-sdnc" -H "X-TransactionId: csit-sdnc" -H "Accept: application/json" -H "Content-Type: application/json" http://localhost:8282/restconf/operations/SLI-API:healthcheck ); echo $response

  if [ "$response" == "200" ]; then
    echo SDNC started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if SDNC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi

#sleep 800

TIME_OUT=1500
INTERVAL=60
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do

docker exec sdnc_controller_container rm -f /opt/opendaylight/current/etc/host.key
response=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client system:start-level)
docker exec sdnc_controller_container rm -f /opt/opendaylight/current/etc/host.key
num_bundles=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | tail -1 | cut -d\| -f1)

  if [ "$response" == "Level 100" ] && [ "$num_bundles" -ge 333 ]; then
    echo SDNC karaf started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if SDNC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: karaf session not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi

response=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client system:start-level)
num_bundles=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | tail -1 | cut -d\| -f1)

  if [ "$response" == "Level 100" ] && [ "$num_bundles" -ge 333 ]; then
    num_bundles=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | tail -1 | cut -d\| -f1)
    num_failed_bundles=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | grep Failure | wc -l)
    failed_bundles=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | grep Failure)
    echo There is/are $num_failed_bundles failed bundles out of $num_bundles installed bundles.
  fi

if [ "$num_failed_bundles" -ge 1 ]; then
  echo "The following bundle(s) are in a failed state: "
  echo "  $failed_bundles"
fi

# Sleep additional 5 minutes (300 secs) to give application time to finish
sleep 300

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"

