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

echo "This is ${WORKSPACE}/test/csit/scripts/vid/start_vid_containers.sh"


RELEASE=vid:latest
CONFIG_PATH=${WORKSPACE}/data/clone/vid/lf_config

export IP=`ifconfig eth0 | awk -F: '/inet addr/ {gsub(/ .*/,"",$2); print $2}'`
export PREFIX='nexus3.onap.org:10001/onap'

#start Maria-DB
docker run --name vid-mariadb -e MYSQL_DATABASE=vid_openecomp_epsdk -e MYSQL_USER=vidadmin -e MYSQL_PASSWORD=Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U -e MYSQL_ROOT_PASSWORD=LF+tp_1WqgSY -v ${CONFIG_PATH}/vid-my.cnf:/etc/mysql/my.cnf -v ${CONFIG_PATH}/vid-schema.sql:/docker-entrypoint-initdb.d/vid-schema.sql -v /var/lib/mysql -d mariadb:10

#start VID server

docker run -e VID_MYSQL_DBNAME=vid_openecomp_epsdk -e VID_MYSQL_PASS=Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U --name vid-server -p 8080:8080 --link vid-mariadb:vid-mariadb-docker-instance -d nexus3.onap.org:10001/onap/${RELEASE}

# WAIT 5 minutes maximum and test every 5 seconds if VID up using HealthCheck API

TIME_OUT=1200
INTERVAL=5
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost:8080/vid/healthCheck); echo $response

  if [ "$response" == "200" ]; then
    echo VID and its database well started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if VID is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for tests...
fi
