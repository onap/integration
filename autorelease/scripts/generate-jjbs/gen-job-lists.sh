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

BUILD_DIR=$ROOT/build
JJB_DIR=$BUILD_DIR/ci-management/jjb

cd $BUILD_DIR

source $ROOT/scripts/generate-jjbs/workarounds.sh


TMPDIR=`mktemp -d`
echo $TMPDIR

mkdir -p $TMPDIR/merge-jobs
find . -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | while read repo; do
    project=${repo}
    OUTFILE=$TMPDIR/merge-jobs/${repo}.txt
 
    has_subprojects=0
    for r in "${SPLIT_REPOS[@]}"; do
	if [ "$repo" = "$r" ]; then
	    has_subprojects=1
	fi
    done

    if [ $has_subprojects -eq 1 ]; then
	poms=`find $repo -mindepth 1 -type d -exec test -e "{}/pom.xml" ';' -prune -printf "%P/pom.xml\n" | sort`
    else
	poms=`find $repo -type d -exec test -e "{}/pom.xml" ';' -prune -printf "%P/pom.xml\n" | sort`
	if [ "$poms" != "/pom.xml" ]; then
	    has_subprojects=1
	fi
    fi
    
    
    if [ $has_subprojects -eq 0 ]; then
	echo ${repo}-master-merge-java > $OUTFILE
    elif [ ! -z "$poms" ]; then
	for pom in $poms; do
	    pompath=${pom%/pom.xml}
	    subproject=${pompath////-} # replace slash with dash
	    echo ${repo}-master-${subproject}-merge-java >> $OUTFILE
	done
    fi
done

