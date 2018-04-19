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
DOCKER_IMAGE_VERSION=latest

echo "This is ${WORKSPACE}/test/csit/scripts/externalapi-nbi/start_nbi_containers.sh"

# Create directory
mkdir -p $WORKSPACE/externalapi-nbi
cd $WORKSPACE/externalapi-nbi

# Fetch the latest docker-compose.yml
wget -O docker-compose.yml 'https://git.onap.org/externalapi/nbi/plain/docker-compose.yml?h=master'

# Pull the nbi docker image from nexus
# MariaDB and mongoDB will be pulled automatically from docker.io during docker-compose
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO
docker pull $NEXUS_DOCKER_REPO/onap/externalapi/nbi:$DOCKER_IMAGE_VERSION

# Start nbi, MariaDB and MongoDB containers with docker compose and nbi/docker-compose.yml
docker-compose up -d mariadb mongo && sleep 5 # to ensure that these services are ready for connections
docker-compose up -d nbi

NBI_IP=$(sudo docker inspect externalapi-nbi_nbi_1 --format='{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}')

echo "IP address for NBI main container is set to ${NBI_IP}."

# Wait for initialization
for i in {1..30}; do
    curl -sS ${NBI_IP}:8080 && break
    echo sleep $i
    sleep $i
done
