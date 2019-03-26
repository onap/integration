#!/bin/bash -x
#
# Copyright 2018 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <docker-proxy>"
    exit 1
fi
DOCKER_PROXY=$1

for MANIFEST in docker-manifest.csv docker-manifest-staging.csv; do
    for DOCKER_IMAGE in $(tail -n +2 $WORKSPACE/version-manifest/src/main/resources/$MANIFEST | tr ',' ':'); do
        docker pull $DOCKER_PROXY/$DOCKER_IMAGE
    done
done
