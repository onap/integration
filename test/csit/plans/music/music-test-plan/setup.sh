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

CASS_IMG=nexus3.onap.org:10001/onap/music/cassandra_music:latest
TOMCAT_IMG=nexus3.onap.org:10001/library/tomcat:8.0
ZK_IMG=nexus3.onap.org:10001/library/zookeeper:3.4
MUSIC_IMG=nexus3.onap.org:10001/onap/music/music:latest
WORK_DIR=/tmp/music
CASS_USERNAME=nelson24
CASS_PASSWORD=winman123
MUSIC_SOURCE_PROPERTIES=${WORKSPACE}/test/csit/scripts/music/music-properties
MUSIC_PROPERTIES=/tmp/music/properties
MUSIC_LOGS=/tmp/music/logs
mkdir -p ${MUSIC_PROPERTIES}
mkdir -p ${MUSIC_LOGS}

cp ${MUSIC_SOURCE_PROPERTIES}/* ${WORK_DIR}/properties

# Create Volume for mapping war file and tomcat
docker volume create --name music-vol;

# Create a network for all the containers to run in.
docker network create music-net;

# Start Cassandra
docker run -d --name music-db --network music-net -p "7000:7000" -p "7001:7001" -p "7199:7199" -p "9042:9042" -p "9160:9160" -e CASSUSER=${CASS_USERNAME} -e CASSPASS=${CASS_PASSWORD} ${CASS_IMG};

# Start Music war
docker run -d --name music-war -v music-vol:/app ${MUSIC_IMG};

# Start Zookeeper
docker run -d --name music-zk --network music-net -p "2181:2181" -p "2888:2888" -p "3888:3888" ${ZK_IMG};

# Delay for Cassandra
sleep 20;

# Start Up tomcat - Needs to have properties,logs dir and war file volume mapped.
docker run -d --name music-tomcat --network music-net -p "8080:8080" -v music-vol:/usr/local/tomcat/webapps -v ${WORK_DIR}/properties:/opt/app/music/etc:ro -v ${WORK_DIR}/logs:/opt/app/music/logs ${TOMCAT_IMG};

# Connect tomcat to host bridge network so that its port can be seen. 
docker network connect bridge music-tomcat;

##################################

#
# add here below the start of all docker containers needed for music CSIT testing
#

CASSA_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' music-db`
echo "CASSANDRA_IP=${CASSA_IP}"

ZOO_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' music-zk`
echo "ZOOKEEPER_IP=${ZOO_IP}"

${WORKSPACE}/test/csit/scripts/music/music-scripts/wait_for_port.sh ${CASSA_IP} 9042

TOMCAT_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' music-tomcat`
echo "TOMCAT_IP=${TOMCAT_IP}"

${WORKSPACE}/test/csit/scripts/music/music-scripts/wait_for_port.sh ${TOMCAT_IP} 8080


echo "inspect docker things for tracing purpose"
docker inspect music-db
docker inspect music-zk
docker inspect music-tomcat
docker inspect music-war
docker volume inspect music-vol
docker network inspect music-net




#
# add here all ROBOT_VARIABLES settings
#
echo "# music robot variables settings";
ROBOT_VARIABLES="-v MUSIC_HOSTNAME:http://${TOMCAT_IP} -v MUSIC_PORT:8080 -v COND_HOSTNAME:http://localhost -v COND_PORT:8091"

echo ${ROBOT_VARIABLES}



