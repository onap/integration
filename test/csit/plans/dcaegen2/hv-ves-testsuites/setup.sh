#!/usr/bin/env bash

set -euo pipefail

echo "Removing not used docker networks"
docker network prune -f

export CONTAINERS_NETWORK=ves-hv-default
echo "Creating network for containers: ${CONTAINERS_NETWORK}"
docker network create ${CONTAINERS_NETWORK}

cd ssl
make FILE=client
make FILE=server
make FILE=invalid_client CA=invalid_trust
cd ..

export DOCKER_REGISTRY="nexus3.onap.org:10001"
CURRENT_DIR=${PWD##*/}
VES_HV_CONTAINER_NAME=ves-hv-collector

# little race condition between container start-up and required files copying below
docker-compose up -d

COMPOSE_VES_HV_CONTAINER_NAME=${CURRENT_DIR}_${VES_HV_CONTAINER_NAME}_1
echo "COPY tls authorization files to container: ${COMPOSE_VES_HV_CONTAINER_NAME}"
docker cp ssl/. ${COMPOSE_VES_HV_CONTAINER_NAME}:/etc/ves-hv
# race condition end


export ROBOT_VARIABLES="--pythonpath ${WORKSPACE}/test/csit/tests/dcaegen2/hv-ves-testcases/libraries"