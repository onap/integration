#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo This script updates HEAT docker versions to use versions in docker-manifest.csv
    echo "$0 <docker-manifest.csv> <demo repo directory>"
    exit 1
fi

# expected parameters
MANIFEST=$(realpath $1)
DEMO_DIR=$(realpath $2)

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

cd $DEMO_DIR/heat/ONAP

source <(./manifest-to-env.sh < $MANIFEST)
envsubst < onap_openstack_template.env > onap_openstack.env
