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

# docker root dir
ROOT=`git rev-parse --show-toplevel`/test/csit/docker

MICROSERVICES=`$ROOT/scripts/ls-microservices.py`

EXIT_CODE=0
for dir in `find $ROOT -maxdepth 1 -mindepth 1 -type d ! -name scripts ! -name templates -printf '%f\n'`; do
    if ! grep -q $dir <<<$MICROSERVICES; then
	echo ERROR: $dir not found in binaries.csv
	EXIT_CODE=1
    fi    
done
exit $EXIT_CODE
