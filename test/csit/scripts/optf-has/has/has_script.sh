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
echo "### This is ${WORKSPACE}/test/csit/scripts/optf-has/has/has_script.sh"
#
# add here whatever commands is needed to prepare the optf/has CSIT testing
#

# assume the base is /tmp dir
DIR=/tmp

# the directory of the script
echo ${DIR}
cd ${DIR}

# create directory for volume and copy configuration file
# run docker containers
COND_CONF=/tmp/conductor/properties/conductor.conf
LOG_CONF=/tmp/conductor/properties/log.conf
IMAGE_NAME=nexus3.onap.org:10001/onap/optf-has
IMAGE_VER=1.2.1-SNAPSHOT-latest
CERT=/tmp/conductor/properties/cert.cer
KEY=/tmp/conductor/properties/cert.key
BUNDLE=/tmp/conductor/properties/cert.pem

mkdir -p /tmp/conductor/properties
mkdir -p /tmp/conductor/logs
cp ${WORKSPACE}/test/csit/scripts/optf-has/has/has-properties/conductor.conf.onap /tmp/conductor/properties/conductor.conf
cp ${WORKSPACE}/test/csit/scripts/optf-has/has/has-properties/log.conf.onap /tmp/conductor/properties/log.conf
cp ${WORKSPACE}/test/csit/scripts/optf-has/has/has-properties/cert.cer /tmp/conductor/properties/cert.cer
cp ${WORKSPACE}/test/csit/scripts/optf-has/has/has-properties/cert.key /tmp/conductor/properties/cert.key
cp ${WORKSPACE}/test/csit/scripts/optf-has/has/has-properties/cert.pem /tmp/conductor/properties/cert.pem
#chmod -R 777 /tmp/conductor/properties

MUSIC_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' music-tomcat`
echo "MUSIC_IP=${MUSIC_IP}"

# change MUSIC reference to the local instance
sed  -i -e "s%localhost:8080/MUSIC%${MUSIC_IP}:8080/MUSIC%g" /tmp/conductor/properties/conductor.conf

AAISIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' aaisim`
echo "AAISIM_IP=${AAISIM_IP}"

# change AAI reference to the local instance
sed  -i -e "s%localhost:8081/%${AAISIM_IP}:8081/%g" /tmp/conductor/properties/conductor.conf

MULTICLOUDSIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' multicloudsim`
echo "MULTICLOUDSIM_IP=${MULTICLOUDSIM_IP}"

# change MULTICLOUD reference to the local instance
sed  -i -e "s%msb.onap.org:8082/%${MULTICLOUDSIM_IP}:8082/%g" /tmp/conductor/properties/conductor.conf

#onboard conductor into music
echo "Query MUSIC to check for reachability. Query Version"
curl -vvvvv --noproxy "*" --request GET http://${MUSIC_IP}:8080/MUSIC/rest/v2/version -H "Content-Type: application/json"
 
echo "Onboard conductor into music"
curl -vvvvv --noproxy "*" --request POST http://${MUSIC_IP}:8080/MUSIC/rest/v2/admin/onboardAppWithMusic -H "Content-Type: application/json" --data @${WORKSPACE}/test/csit/tests/optf-has/has/data/onboard.json

docker run -d --name cond-cont -v ${COND_CONF}:/usr/local/bin/conductor.conf -v ${LOG_CONF}:/usr/local/bin/log.conf ${IMAGE_NAME}:${IMAGE_VER} python /usr/local/bin/conductor-controller --config-file=/usr/local/bin/conductor.conf
sleep 5
docker run -d --name cond-api -p "8091:8091" -v ${COND_CONF}:/usr/local/bin/conductor.conf -v ${LOG_CONF}:/usr/local/bin/log.conf ${IMAGE_NAME}:${IMAGE_VER} python /usr/local/bin/conductor-api --port=8091 -- --config-file=/usr/local/bin/conductor.conf
sleep 5
docker run -d --name cond-solv -v ${COND_CONF}:/usr/local/bin/conductor.conf -v ${LOG_CONF}:/usr/local/bin/log.conf ${IMAGE_NAME}:${IMAGE_VER} python /usr/local/bin/conductor-solver --config-file=/usr/local/bin/conductor.conf
sleep 5
docker run -d --name cond-resv -v ${COND_CONF}:/usr/local/bin/conductor.conf -v ${LOG_CONF}:/usr/local/bin/log.conf ${IMAGE_NAME}:${IMAGE_VER} python /usr/local/bin/conductor-reservation --config-file=/usr/local/bin/conductor.conf
sleep 5
docker run -d --name cond-data -v ${COND_CONF}:/usr/local/bin/conductor.conf -v ${LOG_CONF}:/usr/local/bin/log.conf -v ${CERT}:/usr/local/bin/cert.cer -v ${KEY}:/usr/local/bin/cert.key -v ${BUNDLE}:/usr/local/bin/cert.pem ${IMAGE_NAME}:${IMAGE_VER} python /usr/local/bin/conductor-data --config-file=/usr/local/bin/conductor.conf
sleep 5

COND_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' cond-api`
${WORKSPACE}/test/csit/scripts/optf-has/has/wait_for_port.sh ${COND_IP} 8091

echo "inspect docker things for tracing purpose"
docker inspect cond-data
docker inspect cond-cont
docker inspect cond-api
docker inspect cond-solv
docker inspect cond-resv

echo "dump music content just after conductor is started"
docker exec music-db /usr/bin/nodetool status
docker exec music-db /usr/bin/cqlsh -unelson24 -pwinman123 -e 'SELECT * FROM system_schema.keyspaces'
docker exec music-db /usr/bin/cqlsh -unelson24 -pwinman123 -e 'SELECT * FROM admin.keyspace_master'
