#!/bin/bash -x

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <docker-proxy>"
    exit 1
fi
DOCKER_PROXY=$1

for DOCKER_IMAGE in $(tail -n +2 $WORKSPACE/version-manifest/src/main/resources/docker-manifest.csv | tr ',' ':'); do
    docker pull $DOCKER_PROXY/$DOCKER_IMAGE
done
