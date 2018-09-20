#!/bin/bash
# ========================================================================
# Copyright (c) 2018 Orange
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
# ========================================================================

NEXUS_USERNAME=docker
NEXUS_PASSWD=docker
NEXUS_DOCKER_REPO=nexus3.onap.org:10001
DOCKER_IMAGE_VERSION=2.1.1-latest

echo "This is ${WORKSPACE}/test/csit/scripts/externalapi-nbi/start_nbi_containers.sh"

# Create directory
mkdir -p $WORKSPACE/externalapi-nbi
cd $WORKSPACE/externalapi-nbi

# Create .env file to access env variables for docker-compose
echo "NEXUS_DOCKER_REPO=${NEXUS_DOCKER_REPO}" > .env

# Fetch the latest docker-compose.yml
wget -O docker-compose.yml 'https://git.onap.org/externalapi/nbi/plain/docker-compose.yml?h=master'

# Pull the nbi docker image from nexus
# MariaDB and mongoDB will be pulled automatically from docker.io during docker-compose
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO
docker pull $NEXUS_DOCKER_REPO/onap/externalapi/nbi:$DOCKER_IMAGE_VERSION

# Start nbi, MariaDB and MongoDB containers with docker compose and nbi/docker-compose.yml
docker-compose up -d mariadb mongo

# inject a script to ensure that these services are ready for connections
docker-compose run --rm --entrypoint='/bin/sh' nbi -c '\
    attempt=1; \
    while ! nc -z mariadb 3306 || ! nc -z mongo 27017; do \
        if [ $attempt = 30 ]; then \
            echo "Timed out!"; \
            exit 1; \
        fi; \
        echo "waiting for db services (attempt #$attempt)..."; \
        sleep 1; \
        attempt=$(( attempt + 1)); \
    done; \
    echo "all db services are ready for connections!" \
'

docker-compose up -d nbi

NBI_CONTAINER_NAME=$(docker-compose ps 2> /dev/null | tail -n+3 | tr -s ' ' | cut -d' ' -f1 | grep _nbi_)
NBI_IP=$(docker inspect --format='{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' ${NBI_CONTAINER_NAME})

echo "IP address for NBI main container ($NBI_CONTAINER_NAME) is set to ${NBI_IP}."

# Wait for initialization
for i in {1..30}; do
    curl -sS ${NBI_IP}:8080 > /dev/null 2>&1 && echo 'nbi initialized' && break
    echo sleep $i
    sleep $i
done
