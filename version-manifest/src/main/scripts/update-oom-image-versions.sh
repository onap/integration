#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo This script updates OOM helm charts to use versions in docker-manifest.csv
    echo "$0 <docker-manifest.csv> <oom directory>"
    exit 1
fi

# expected parameters
MANIFEST=$(realpath $1)
OOM_DIR=$(realpath $2)

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

DIR=$(dirname $(readlink -f "$0"))
TARGET_DIR=$DIR/target
rm -rf $TARGET_DIR
mkdir -p $TARGET_DIR
cd $TARGET_DIR

cd $OOM_DIR/kubernetes

for line in $(tail -n +2 $MANIFEST); do
    image=$(echo $line | cut -d , -f 1)
    tag=$(echo $line | cut -s -d , -f 2)
    perl -p -i -e "s|image:.*$image.*|image: $image:$tag|g" $(find ./ -name values.yaml)
done

