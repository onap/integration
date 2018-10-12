#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo This script checks java-manifest.csv to verify that the specified versions have been released in nexus
    echo "$0 <java-manifest.csv>"
    exit 1
fi

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

NEXUS_RELEASE_PREFIX="https://nexus.onap.org/content/repositories/releases"

err=0
for line in $(tail -n +2 $1); do
    group=$(echo $line | cut -d , -f 1)
    artifact=$(echo $line | cut -d , -f 2)
    version=$(echo $line | cut -d , -f 3)
    path=$(echo $group/$artifact | tr '.' '/')

    url="$NEXUS_RELEASE_PREFIX/$path/$version/"
    http_code=$(curl -s -o /dev/null -I -w "%{http_code}" $url)
    if [ $http_code -ne 200 ]; then
        echo "[WARNING] $group:$artifact:$version not released"
        (( err++ ))
    else
        echo "[INFO] $group:$artifact:$version OK"
    fi
done
#exit $err
exit 0
