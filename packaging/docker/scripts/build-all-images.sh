#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# $1 org

if [ -z "$1" ]; then
    ORG="openoint"
else
    ORG=$1
fi

set -exu

VERSION="1.1.0-SNAPSHOT"

# docker root dir
ROOT=`git rev-parse --show-toplevel`/test/csit/docker

cd $ROOT
for image in `$ROOT/scripts/ls-microservices.py | sort`; do
    echo 
    echo $image
    docker build -t $ORG/$image:$VERSION -t $ORG/$image:latest $image/target
done
