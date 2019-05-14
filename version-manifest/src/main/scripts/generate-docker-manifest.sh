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
    echo This script creates a docker manifest using OOM helm charts as source
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

echo "image,tag" > $MANIFEST.tmp
rgrep -h -E ':\s*onap/.*:.*' | awk '{$1=$1};1' | cut -d' ' -f2 | tr ':' ',' >> $MANIFEST.tmp
LC_ALL=C sort -u < $MANIFEST.tmp > $MANIFEST
rm $MANIFEST.tmp
