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

# csit plans root dir
ROOT=`git rev-parse --show-toplevel`/autorelease

BUILD_DIR=$ROOT/build
JJB_DIR=$BUILD_DIR/ci-management/jjb

WORKSPACE=`git rev-parse --show-toplevel`
PLANS_DIR=`git rev-parse --show-toplevel`/test/csit/plans

source $ROOT/scripts/generate-jjbs/workarounds.sh


TMPDIR=`mktemp -d --suffix="-docker-log"`
$ROOT/scripts/ls-microservice-repos.py | cut -d ' ' -f 1 > $TMPDIR/microservices.txt

find $PLANS_DIR -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | while read repo; do

    OUTFILE=$JJB_DIR/$repo/${repo}-csit.yaml
    cat > $OUTFILE <<EOF
---
- project:
    name: ${repo}-csit
    jobs:
      - 'integration-verify-{project}-csit-{functionality}'
      - '{project}-csit-{functionality}'
    project: '${repo}'
    functionality:
EOF
    find $PLANS_DIR/$repo -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | while read func; do
	echo $repo / $func
	cat >> $OUTFILE <<EOF
      - '${func}':
          trigger_jobs:
EOF

	docker kill `docker ps -a -q`
	docker rm `docker ps -a -q`

	$WORKSPACE/test/csit/run-csit.sh plans/${repo}/${func}
	mkdir -p $TMPDIR/${repo}
	cp $WORKSPACE/archives/_docker-images.log $TMPDIR/${repo}/${func}.txt
	
	docker kill `docker ps -a -q`
	docker rm `docker ps -a -q`
	
	
	for image in `grep openoint $TMPDIR/${repo}/${func}.txt | grep -f $TMPDIR/microservices.txt | sort`; do
	    microservice=`echo $image | cut -d '/' -f 2`
	    cat >> $OUTFILE <<EOF
            - 'integration-${microservice}-merge-docker'
EOF
	done

    done

    cat >> $OUTFILE <<EOF
    robot-options: ''
    branch: 'master'
EOF
done

echo $TMPDIR
