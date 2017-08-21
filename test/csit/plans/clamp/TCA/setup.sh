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
source ${WORKSPACE}/test/csit/scripts/clamp/script1.sh

# Clone Clamp repo to get extra folder that has all needed to run docker with docker-compose to start DB and Clamp
mkdir -p $WORKSPACE/archives/clamp-clone
cd $WORKSPACE/archives/clamp-clone
git clone --depth 1 http://gerrit.onap.org/r/clamp -b master
cd clamp/extra/docker/clamp/

# start Clamp and MariaDB containers with docker compose and configuration from clamp/extra/docker/clamp/docker-compose.yml
docker-compose up -d

# WAIT 5 minutes maximum and test every 5 seconds if Clamp up using HealthCheck API
TIME_OUT=300
INTERVAL=5
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost:8080/restservices/clds/v1/clds/healthcheck); echo $response

  if [ "$response" == "200" ]; then
    echo Clamp and its database well started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if Clamp is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for tests...
fi

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
#ROBOT_VARIABLES="-v TEST:${TEST}"

