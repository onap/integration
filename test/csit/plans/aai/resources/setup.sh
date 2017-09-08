#!/bin/bash
#
# Copyright © 2017 AT&T Intellectual Property.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ECOMP is a trademark and service mark of AT&T Intellectual Property.

source ${SCRIPTS}/common_functions.sh

NEXUS_USERNAME=$(cat /opt/config/nexus_username.txt)
NEXUS_PASSWD=$(cat /opt/config/nexus_password.txt)
NEXUS_DOCKER_REPO=$(cat /opt/config/nexus_docker_repo.txt)
DOCKER_IMAGE_VERSION=$(cat /opt/config/docker_version.txt)
DOCKER_REGISTRY=${NEXUS_DOCKER_REPO}
DOCKER_IMAGE_VERSION=$(cat /opt/config/docker_version.txt)

docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO

function wait_for_container() {

    CONTAINER_NAME="$1";
    START_TEXT="$2";

    TIMEOUT=160

    # wait for the real startup
    AMOUNT_STARTUP=$(docker logs ${CONTAINER_NAME} 2>&1 | grep "$START_TEXT" | wc -l)
    while [[ ${AMOUNT_STARTUP} -ne 1 ]];
    do
        echo "Waiting for '$CONTAINER_NAME' deployment to finish ..."
        AMOUNT_STARTUP=$(docker logs ${CONTAINER_NAME} 2>&1 | grep "$START_TEXT" | wc -l)
        if [ "$TIMEOUT" = "0" ];
        then
            echo "ERROR: $CONTAINER_NAME deployment failed."
            exit 1
        fi
        let TIMEOUT-=1
        sleep 1
    done
}

DOCKER_COMPOSE_CMD="docker-compose";
export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1);
export DOCKER_REGISTRY="nexus3.onap.org:10001";
export HBASE_IMAGE="${HBASE_IMAGE:-harisekhon/hbase}";

docker pull ${DOCKER_REGISTRY}/openecomp/aai-resources:${DOCKER_IMAGE_VERSION};
docker tag ${DOCKER_REGISTRY}/openecomp/aai-resources:${DOCKER_IMAGE_VERSION} ${DOCKER_REGISTRY}/openecomp/aai-resources:latest;

docker pull ${DOCKER_REGISTRY}/openecomp/aai-traversal:${DOCKER_IMAGE_VERSION};
docker tag ${DOCKER_REGISTRY}/openecomp/aai-traversal:${DOCKER_IMAGE_VERSION} ${DOCKER_REGISTRY}/openecomp/aai-traversal:latest;

${DOCKER_COMPOSE_CMD} stop
${DOCKER_COMPOSE_CMD} rm -f -v

# Start the hbase where the data will be stored
HBASE_CONTAINER_NAME=$(${DOCKER_COMPOSE_CMD} up -d aai.hbase.simpledemo.openecomp.org 2>&1 | grep 'Creating' | grep -v 'volume' | grep -v 'network' | awk '{ print $2; }' | head -1);
wait_for_container ${HBASE_CONTAINER_NAME} ' Started SelectChannelConnector@0.0.0.0:8085';
wait_for_container ${HBASE_CONTAINER_NAME} ' Started SelectChannelConnector@0.0.0.0:8080';
wait_for_container ${HBASE_CONTAINER_NAME} ' Started SelectChannelConnector@0.0.0.0:9095';

# Start the resources microservice
RESOURCES_CONTAINER_NAME=$(${DOCKER_COMPOSE_CMD} up -d aai-resources.api.simpledemo.openecomp.org 2>&1 | grep 'Creating' | grep -v 'volume' | grep -v 'network' | awk '{ print $2; }' | head -1);
wait_for_container ${RESOURCES_CONTAINER_NAME} '0.0.0.0:8447';

# Start the traversal microservice
GRAPH_CONTAINER_NAME=$($DOCKER_COMPOSE_CMD up -d aai-traversal.api.simpledemo.openecomp.org 2>&1 | grep 'Creating' | awk '{ print $2; }' | head -1);
wait_for_container ${GRAPH_CONTAINER_NAME} '0.0.0.0:8446';

# Start the haproxy to route requests between resources and traversal
HAPROXY_CONTAINER_NAME=$(${DOCKER_COMPOSE_CMD} up -d aai.api.simpledemo.openecomp.org 2>&1 |grep 'Creating' | grep -v 'volume' | grep -v 'network' | awk '{ print $2; }' | head -1);

echo "A&AI Microservices, resources and traversal, are up and running along with HAProxy";

docker exec -it $GRAPH_CONTAINER_NAME "/opt/app/aai-traversal/scripts/install/updateQueryData.sh" && {
	echo "Successfully loaded the widget related data into db";
} || {
	echo "Unable to load widget related data into db";
}

HAPROXY_IP=$(${SCRIPTS}/get-instance-ip.sh ${HAPROXY_CONTAINER_NAME});
# Set the host ip for robot from the haproxy
ROBOT_VARIABLES="-v HOST_IP:${HAPROXY_IP}"
