#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo This script checks docker-manifest.csv to verify that the specified versions have been released in nexus3
    echo "$0 <docker-manifest.csv>"
    exit 1
fi

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

NEXUS_PUBLIC_PREFIX="https://nexus3.onap.org/repository/docker.public/v2"
NEXUS_RELEASE_PREFIX="https://nexus3.onap.org/repository/docker.release/v2"

err=0
for line in $(tail -n +2 $1); do
    image=$(echo $line | cut -d , -f 1)
    tag=$(echo $line | cut -d , -f 2)

    tags=$(curl -s $NEXUS_RELEASE_PREFIX/$image/tags/list | jq -r '.tags[]' 2> /dev/null)
    echo "$tags" | grep -q "^$tag\$"
    if [ $? -ne 0 ]; then
        echo "[ERROR] $image:$tag not released"
        #echo "$tags" | sed 's/^/  /'
        (( err++ ))
    else
        echo "[INFO] $image:$tag OK"
    fi
done
exit $err
