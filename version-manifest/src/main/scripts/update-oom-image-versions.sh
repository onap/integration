#!/bin/bash

realpath() {
  OURPWD="$PWD"
  cd "$(dirname "$1")"
  LINK=$(readlink "$(basename "$1")")
  while [ "$LINK" ]; do
    cd "$(dirname "$LINK")"
    LINK=$(readlink "$(basename "$1")")
  done
  REALPATH="$PWD/$(basename "$1")"
  cd "$OURPWD"
  echo "$REALPATH"
}

if [ "$#" -ne 2 ]; then
    echo This script updates OOM helm charts to use versions in docker-manifest.csv
    echo "$0 <docker-manifest.csv> <oom repo directory>"
    exit 1
fi

# expected parameters
MANIFEST=$(realpath $1)
OOM_DIR=$(realpath $2)

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

cd $OOM_DIR/kubernetes

for line in $(tail -n +2 $MANIFEST); do
    image=$(echo $line | cut -d , -f 1)
    tag=$(echo $line | cut -s -d , -f 2)
    perl -p -i -e "s|$image(:.*$\|$)|$image:$tag|g" $(find ./ -name values.yaml)
done

