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

    if [[ "${staging//./-}_" < "${release//./-}_" ]]; then
        echo "[ERROR] $image:$staging is out-of-date vs. release ($release)."

        # Uncomment the following to update the staging manifest with the release version
        # sed -i "s|$image,.*|$image,$release|g" $2
    fi
done
exit $err
