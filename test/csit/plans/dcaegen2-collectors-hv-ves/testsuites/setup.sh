#!/usr/bin/env bash

set -euo pipefail

pip uninstall -y docker-py
pip install docker

COMPOSE_VERSION=1.22.0
COMPOSE_LOCATION='/usr/local/bin/docker-compose'
sudo curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o ${COMPOSE_LOCATION}
sudo chmod +x ${COMPOSE_LOCATION}


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
docker-compose up -d

mkdir ${WORKSPACE}/archives/containers_logs

export ROBOT_VARIABLES="--pythonpath ${WORKSPACE}/test/csit/tests/dcaegen2-collectors-hv-ves/testcases/libraries"