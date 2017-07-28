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

# autorelease root dir
ROOT=`git rev-parse --show-toplevel`/autorelease
GERRIT_BRANCH='master'

cd $ROOT
git checkout build

BUILD_DIR=$ROOT/build
cd $BUILD_DIR

$ROOT/scripts/clone-all.sh
$ROOT/scripts/generate-pom.sh
$ROOT/scripts/fix-relativepaths.sh
$ROOT/scripts/set-version.sh

TMPDIR=`mktemp -d`
mvn -q clean deploy -DdisableJavaSdkAutoGeneration -DaltDeploymentRepository=staging::default::file:$TMPDIR -DskipTests=true -Dcheckstyle.skip=true
echo "TMPDIR=$TMPDIR"
