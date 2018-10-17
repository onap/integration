#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo This script adds new docker images from OOM helm charts into docker-manifest.csv
    echo "$0 <docker-manifest.csv> <oom repo directory>"
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

cd $OOM_DIR
rgrep -i "image: .*" --include=values.yaml -h | awk '{ $1=$1; print }' | cut -d ' ' -f 2 | tr -d '"'| grep -v '<' | grep -e "^onap" -e "^openecomp" | LC_ALL=C sort -u > $TARGET_DIR/oom-manifest.txt
touch $TARGET_DIR/docker-manifest-new-entries.txt

for line in $(cat $TARGET_DIR/oom-manifest.txt); do
    image=$(echo $line | cut -d : -f 1)
    tag=$(echo $line | cut -s -d : -f 2)
    if [ -z "$tag" ]; then
        tag="latest"
    fi
    if ! grep -q "$image" $MANIFEST; then
        echo $image,$tag >> $TARGET_DIR/docker-manifest-new-entries.txt
    fi
done

cat $MANIFEST $TARGET_DIR/docker-manifest-new-entries.txt | LC_ALL=C sort -u > $MANIFEST.tmp
mv $MANIFEST.tmp $MANIFEST
