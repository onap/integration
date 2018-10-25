#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo This script compares docker-manifest.csv with docker-manifest-staging.csv to verify that staging has later versions than release.
    echo "$0 <docker-manifest.csv> <docker-manifest-staging.csv>"
    exit 1
fi

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

export LC_ALL=C

err=0
for line in $(join -t, $1 $2 | tail -n +2); do
    image=$(echo $line | cut -d , -f 1)
    release=$(echo $line | cut -d , -f 2)
    staging=$(echo $line | cut -d , -f 3)

    if [[ "${staging}_" < "${release}_" ]]; then
        echo "[WARNING] $image:$staging is older than $release."
    fi
done
exit $err
