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

#
# add here eventual scripts needed for music
#
echo "# music scripts calling";
source ${WORKSPACE}/test/csit/scripts/music/music-scripts/music_script.sh

#
# add here all the configuration steps eventually needed to be carried out for music CSIT testing
#
echo "# music configuration step";
MUSIC_SOURCE_PROPERTIES=${WORKSPACE}/test/csit/scripts/music/music-properties
MUSIC_PROPERTIES=/tmp/music/properties
MUSIC_LOGS=/tmp/music/logs

mkdir -p ${MUSIC_PROPERTIES}
mkdir -p ${MUSIC_LOGS}

cp ${MUSIC_SOURCE_PROPERTIES}/* ${MUSIC_PROPERTIES}

#docker cp /home/lb7254/integration/test/csit/scripts/music/music-scripts/music_init.cql cassandra:/tmp/music_init.cql
#docker cp ${WORKSPACE}/test/csit/scripts/music/music-scripts/music_init.cql cassandra:/tmp/music_init.cql
#docker exec -it cassandra /usr/bin/cqlsh -umusic -pmusic  -f /tmp/music_init.cql



#
# add here below the start of all docker containers needed for music CSIT testing
#
echo "# music docker containers spinoff";


docker volume create --name music-vol
docker run -d --name music-war -v music-vol:/app nexus3.onap.org:10001/onap/music/music:latest
docker run -d --name music-db -p 7000:7000 -p 7001:7001 -p 7199:7199 -p 9042:9042 -p 9160:9160 nexus3.onap.org:10001/onap/music/cassandra_music:latest
docker run -d --name music-zk -p 2181:2181 -p 2888:2888 -p 3888:3888 nexus3.onap.org:10001/library/zookeeper:3.4
sleep 30

CASSA_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' music-db`
echo "CASSANDRA_IP=${CASSA_IP}"

ZOO_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' music-zk`
echo "ZOOKEEPER_IP=${ZOO_IP}"

${WORKSPACE}/test/csit/scripts/music/music-scripts/wait_for_port.sh ${CASSA_IP} 9042

docker run -d --name music-tomcat -p 8080:8080 -v music-vol:/usr/local/tomcat/webapps -v ${MUSIC_PROPERTIES}:/opt/app/music/etc:ro -v ${MUSIC_LOGS}:/opt/app/music/logs nexus3.onap.org:10001/library/tomcat:8.0
sleep 10

TOMCAT_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' music-tomcat`
echo "TOMCAT_IP=${TOMCAT_IP}"

${WORKSPACE}/test/csit/scripts/music/music-scripts/wait_for_port.sh ${TOMCAT_IP} 8080


--- old part: it will be removed
#docker run --name cassandra -d -p 9042:9042 -p 7000:7000 -p 7001:7001 -p 7199:7199 -p 9160:9160 nexus3.onap.org:10001/library/cassandra 
#docker run --name zookeeper -d -p 2181:2181 -p 2888:2888 -p 3888:3888 nexus3.onap.org:10001/library/zookeeper
#docker run --name music -d -v /app nexus3.onap.org:10001/music
#docker run --name tomcat -d -p 8080:8080 --volumes-from music nexus3.onap.org:10001/library/tomcat




#
# add here all ROBOT_VARIABLES settings
#
echo "# music robot variables settings";
ROBOT_VARIABLES="-v MUSIC_HOSTNAME:http://${TOMCAT_IP} -v MUSIC_PORT:8080 -v COND_HOSTNAME:http://localhost -v COND_PORT:8091"

echo ${ROBOT_VARIABLES}



