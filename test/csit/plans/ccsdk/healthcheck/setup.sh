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
source ${WORKSPACE}/test/csit/scripts/ccsdk/script1.sh

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)
export NEXUS_DOCKER_REPO="nexus3.onap.org:10001"
export NEXUS_USERNAME=docker
export NEXUS_PASSWD=docker
export DMAAP_TOPIC=AUTO
export CCSDK_DOCKER_IMAGE_VERSION=0.3-STAGING-latest

if [ "$MTU" == "" ]; then
	  export MTU="1450"
fi


# Clone CCSDK repo to get docker-compose for CCSDK
mkdir -p $WORKSPACE/archives/ccsdk
cd $WORKSPACE/archives
git clone -b master --single-branch http://gerrit.onap.org/r/ccsdk/distribution.git ccsdk
cd $WORKSPACE/archives/ccsdk
git pull
unset http_proxy https_proxy
cd $WORKSPACE/archives/ccsdk/src/main/yaml

sed -i "s/DMAAP_TOPIC_ENV=.*/DMAAP_TOPIC_ENV="AUTO"/g" docker-compose.yml
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO

docker pull $NEXUS_DOCKER_REPO/onap/ccsdk-odl-image:$CCSDK_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/ccsdk-odl-image:$CCSDK_DOCKER_IMAGE_VERSION onap/ccsdk-odl-image:0.3-STAGING-latest

docker pull $NEXUS_DOCKER_REPO/onap/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION onap/ccsdk-dgbuilder-image:0.3-STAGING-latest

docker pull $NEXUS_DOCKER_REPO/onap/ccsdk-odlsli-image:$CCSDK_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/ccsdk-odlsli-image:$CCSDK_DOCKER_IMAGE_VERSION onap/ccsdk-odlsli-image:0.3-STAGING-latest

# start CCSDK containers with docker compose and configuration from docker-compose.yml
curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
./docker-compose up -d

# WAIT 5 minutes maximum and test every 5 seconds if CCSDK is up using HealthCheck API
TIME_OUT=500
INTERVAL=30
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: Basic YWRtaW46YWRtaW4=" -X POST -H "X-FromAppId: csit-ccsdk" -H "X-TransactionId: csit-ccsdk" -H "Accept: application/json" -H "Content-Type: application/json" http://localhost:8383/restconf/operations/SLI-API:healthcheck ); echo $response

  if [ "$response" == "200" ]; then
    echo CCSDK started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if CCSDK is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
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

docker exec ccsdk_odlsli_container rm -f /opt/opendaylight/current/etc/host.key
response=$(docker exec ccsdk_odlsli_container /opt/opendaylight/current/bin/client system:start-level)
docker exec ccsdk_odlsli_container rm -f /opt/opendaylight/current/etc/host.key
num_bundles=$(docker exec ccsdk_odlsli_container /opt/opendaylight/current/bin/client bundle:list | tail -1 | cut -d\| -f1)

  if [ "$response" == "Level 100" ] && [ "$num_bundles" -ge 333 ]; then
    echo CCSDK karaf started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if CCSDK is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: karaf session not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi

response=$(docker exec ccsdk_odlsli_container /opt/opendaylight/current/bin/client system:start-level)
num_bundles=$(docker exec ccsdk_odlsli_container /opt/opendaylight/current/bin/client bundle:list | tail -1 | cut -d\| -f1)

  if [ "$response" == "Level 100" ] && [ "$num_bundles" -ge 333 ]; then
    num_bundles=$(docker exec ccsdk_odlsli_container /opt/opendaylight/current/bin/client bundle:list | tail -1 | cut -d\| -f1)
    num_failed_bundles=$(docker exec ccsdk_odlsli_container /opt/opendaylight/current/bin/client bundle:list | grep Failure | wc -l)
    failed_bundles=$(docker exec ccsdk_odlsli_container /opt/opendaylight/current/bin/client bundle:list | grep Failure)
    echo There is/are $num_failed_bundles failed bundles out of $num_bundles installed bundles.
  fi

if [ "$num_failed_bundles" -ge 1 ]; then
  echo "The following bundle(s) are in a failed state: "
  echo "  $failed_bundles"
fi

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"

