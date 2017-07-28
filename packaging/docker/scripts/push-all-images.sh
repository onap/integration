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

set -ex

VERSION="1.1.0-SNAPSHOT"

# docker root dir
ROOT=`git rev-parse --show-toplevel`/test/csit/docker

if [ -z "$MVN" ]; then
    export MVN=`which mvn`
fi
if [ -z "$MVN" ] && [ -x /w/tools/hudson.tasks.Maven_MavenInstallation/mvn33/bin/mvn ]; then
    export MVN="/w/tools/hudson.tasks.Maven_MavenInstallation/mvn33/bin/mvn"
fi

cd $ROOT
for image in `$ROOT/scripts/ls-microservices.py | sort`; do
    echo
    echo $image

    if [ ! -z "$MVN" ]; then
	$MVN -f $image/target docker:push
    else
	docker push $ORG/$image:$VERSION
	docker push $ORG/$image:latest
    fi
done
