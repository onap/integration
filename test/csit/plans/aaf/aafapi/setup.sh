#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP AAF
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
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

# Clone AAF Authz repo
mkdir -p $WORKSPACE/archives/aafcsit
cd $WORKSPACE/archives/aafcsit
#unset http_proxy https_proxy
git clone --depth 1 http://gerrit.onap.org/r/aaf/authz -b master
git pull
cd $WORKSPACE/archives/aafcsit/authz/auth/auth-service/src/main/resources/docker-compose
pwd
chmod -R 777 $WORKSPACE/archives/aafcsit/authz/auth/auth-service/src/main/resources/docker-compose


# start aaf containers with docker compose and configuration from docker-compose.yml
docker-compose up -d

# Wait for initialization of Docker contaienr for AAF & Cassandra
for i in {1..12}; do
	if [ $(docker inspect --format '{{ .State.Running }}' dockercompose_aaf_container_1) ] && \
		[ $(docker inspect --format '{{ .State.Running }}' dockercompose_cassandra_container_1) ] && \
		[ $(docker inspect --format '{{ .State.Running }}' dockercompose_aaf_container_1) ]
	then
		echo "AAF Service Running"
		break
	else
		echo sleep $i
		sleep $i
	fi
done


AAF_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_aaf_container_1)
CASSANDRA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_cassandra_container_1)


echo AAF_IP=${AAF_IP}
echo CASSANDRA_IP=${CASSANDRA_IP}


# Wait for initialization of docker services
for i in {1..12}; do
    curl -sS -m 1 ${AAF_IP}:8101 && break
    echo sleep $i
    sleep $i
done

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v AAF_IP:${AAF_IP}"
