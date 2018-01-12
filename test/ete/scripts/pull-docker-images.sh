#!/bin/bash -x

# this script will pull all the docker images listed in the manifest
# specify a parameter to override the default proxy of nexus3.onap.org:100001

if [ "$#" -ne 1 ]; then
    PROXY=nexus3.onap.org:10001
else
    PROXY=$1
fi


if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

MANIFEST=${WORKSPACE}/version-manifest/src/main/resources/docker-manifest.csv
IMAGES=$(tail -n +2 $MANIFEST | tr ',' ':')

for image in $IMAGES; do
    docker pull ${PROXY}/${image}
done
