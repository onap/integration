#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CLAMP
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#

echo "This is ${WORKSPACE}/test/csit/scripts/clamp/start_clamp_containers.sh"

# start Clamp and MariaDB containers with docker compose and configuration from clamp/extra/docker/clamp/docker-compose.yml
docker-compose up -d

# Certificate need the host to have this name
echo '172.18.0.4       clamp.api.simpledemo.onap.org' >> /etc/hosts

# WAIT 5 minutes maximum and test every 5 seconds if Clamp up using HealthCheck API
TIME_OUT=200
INTERVAL=5
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null -vk --key config/org.onap.clamp.keyfile https://clamp.api.simpledemo.onap.org:8443/restservices/clds/v1/clds/healthcheck); echo $response

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

# To avoid some problem because templates not yet read
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null  -vk --key config/org.onap.clamp.keyfile  -u admin:password https://clamp.api.simpledemo.onap.org:8443/restservices/clds/v1/cldsTempate/template-names); echo $response

  if [ "$response" == "200" ]; then
    echo Templates well available
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if templates available. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Templates not available in $TIME_OUT seconds... Could cause problems for tests...
fi

hostname
cat /etc/hosts

docker inspect clamp_clamp_1
