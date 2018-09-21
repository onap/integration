#!/usr/bin/env bash

set -euo pipefail

if [[ $# -eq 1 ]] && [[ $1 == "local-test-run" ]]; then
  echo "Building locally - assuming all dependencies are installed"
  export DOCKER_REGISTRY=""
  export DOCKER_REGISTRY_PREFIX=""
  export WORKSPACE=$(git rev-parse --show-toplevel)
else
  echo "Default run - install all dependencies"

  pip uninstall -y docker-py
  pip install docker

  COMPOSE_VERSION=1.22.0
  COMPOSE_LOCATION='/usr/local/bin/docker-compose'
  sudo curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o ${COMPOSE_LOCATION}
  sudo chmod +x ${COMPOSE_LOCATION}

  export DOCKER_REGISTRY="nexus3.onap.org:10001"
  export DOCKER_REGISTRY_PREFIX="${DOCKER_REGISTRY}/"
fi

echo "Removing not used docker networks"
docker network prune -f

export CONTAINERS_NETWORK=ves-hv-default
echo "Creating network for containers: ${CONTAINERS_NETWORK}"
docker network create ${CONTAINERS_NETWORK}

cd ssl
./gen-certs.sh
cd ..

docker-compose up -d

mkdir -p ${WORKSPACE}/archives/containers_logs

export ROBOT_VARIABLES="--pythonpath ${WORKSPACE}/test/csit/tests/dcaegen2-collectors-hv-ves/testcases/libraries"
