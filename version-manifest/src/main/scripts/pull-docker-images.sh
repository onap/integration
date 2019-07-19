#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo This script pulls all the ONAP docker images contained in OOM helm charts
    echo "$0 <oom repo directory> <proxy URL>"
    exit 1
fi

OOM_DIR=$(realpath $1)
PROXY="nexus3.onap.org:10001"

if [ "$#" -eq 2 ]; then
    PROXY=$2
fi


if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi


MANIFEST=$(mktemp --suffix=-docker-manifest.csv)
$WORKSPACE/version-manifest/src/main/scripts/generate-docker-manifest.sh $MANIFEST $OOM_DIR
IMAGES=$(tail -n +2 $MANIFEST | tr ',' ':')

for image in $IMAGES; do
    docker pull ${PROXY}/${image}
done
