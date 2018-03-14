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
DOCKER_IMAGE_VERSION=1.2-STAGING-latest

export CURRENT_PWD=$(pwd);

function wait_for_container() {

    CONTAINER_NAME="$1";
    START_TEXT="$2";

    TIMEOUT=360

    # wait for the real startup
    AMOUNT_STARTUP=$(docker logs ${CONTAINER_NAME} 2>&1 | grep "$START_TEXT" | wc -l)
    while [[ ${AMOUNT_STARTUP} -ne 1 ]];
    do
        echo "Waiting for '$CONTAINER_NAME' deployment to finish ..."
        AMOUNT_STARTUP=$(docker logs ${CONTAINER_NAME} 2>&1 | grep "$START_TEXT" | wc -l)
        if [ "$TIMEOUT" = "0" ];
        then
            docker logs ${CONTAINER_NAME};
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
export AAI_HAPROXY_IMAGE="${AAI_HAPROXY_IMAGE:-aaionap/haproxy}";
export HAPROXY_VERSION="${HAPROXY_VERSION:-1.2.0}";
export HBASE_IMAGE="${HBASE_IMAGE:-aaionap/hbase}";
export HBASE_VERSION="${HBASE_VERSION:-1.2.0}";

docker pull ${HBASE_IMAGE}:${HBASE_VERSION};

docker pull ${DOCKER_REGISTRY}/onap/aai-resources:${DOCKER_IMAGE_VERSION};
docker tag ${DOCKER_REGISTRY}/onap/aai-resources:${DOCKER_IMAGE_VERSION} ${DOCKER_REGISTRY}/onap/aai-resources:latest;

docker pull ${DOCKER_REGISTRY}/onap/aai-traversal:${DOCKER_IMAGE_VERSION};
docker tag ${DOCKER_REGISTRY}/onap/aai-traversal:${DOCKER_IMAGE_VERSION} ${DOCKER_REGISTRY}/onap/aai-traversal:latest;

${DOCKER_COMPOSE_CMD} stop
${DOCKER_COMPOSE_CMD} rm -f -v

# Start the hbase where the data will be stored
HBASE_CONTAINER_NAME=$(${DOCKER_COMPOSE_CMD} up -d aai.hbase.simpledemo.onap.org 2>&1 | grep 'Creating' | grep -v 'volume' | grep -v 'network' | awk '{ print $2; }' | head -1);
wait_for_container ${HBASE_CONTAINER_NAME} ' Started SelectChannelConnector@0.0.0.0:8085';
wait_for_container ${HBASE_CONTAINER_NAME} ' Started SelectChannelConnector@0.0.0.0:8080';
wait_for_container ${HBASE_CONTAINER_NAME} ' Started SelectChannelConnector@0.0.0.0:9095';

USER_EXISTS=$(check_if_user_exists aaiadmin);

function check_if_user_exists(){
    local user_id=$1;

    if [ -z "$user_id" ]; then
        echo "Needs to provide at least one argument for check_if_user_exists func";
        exit 1;
    fi;

    id -u ${user_id} > /dev/null 2>&1 && {
        echo "1";
    } || {
        echo "0";
    }
}


if [ "${USER_EXISTS}" -eq 0 ]; then
        export USER_ID=9000;
        export GROUP_ID=9000;
else
        export USER_ID=$(id -u aaiadmin);
        export GROUP_ID=$(id -g aaiadmin);
fi;

RESOURCES_CONTAINER_NAME=$(${DOCKER_COMPOSE_CMD} up -d aai-resources.api.simpledemo.onap.org 2>&1 | grep 'Creating' | grep -v 'volume' | grep -v 'network' | awk '{ print $2; }' | head -1);
wait_for_container $RESOURCES_CONTAINER_NAME 'Resources Microservice Started';

${DOCKER_COMPOSE_CMD} up -d aai-traversal.api.simpledemo.onap.org aai.api.simpledemo.onap.org
echo "A&AI Microservices, resources and traversal, are up and running along with HAProxy";

wait_for_container 'Traversal Microservice Started';
# Set the host ip for robot from the haproxy
ROBOT_VARIABLES="-v HOST_IP:`ip addr show docker0 | head -3 | tail -1 | cut -d' ' -f6 | cut -d'/' -f1`"
