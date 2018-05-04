#!/bin/bash

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

NEXUS_PREFIX="https://nexus3.onap.org/repository/docker.public/v2"

err=0
for line in $(tail -n +2 $1); do
    image=$(echo $line | cut -d , -f 1)
    tag=$(echo $line | cut -d , -f 2)
    tags=$(curl -s $NEXUS_PREFIX/$image/tags/list | jq -r '.tags[]')
    echo "$tags" | grep -q "^$tag\$"
    if [ $? -ne 0 ]; then
        echo "[ERROR] $image:$tag not found"
        echo "$tags" | sed 's/^/  /'
        (( err++ ))
    fi
done
exit $err
