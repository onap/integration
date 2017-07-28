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


find . -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | while read repo; do
    project=${repo}
 
    toxs=`find $repo -type d -exec test -e "{}/tox.ini" ';' -prune -printf "%P/tox.ini\n" | sort`

    in_sun_branch=`git show sun:autorelease/all-projects.txt | grep -x ${repo}`

    mkdir -p $JJB_DIR/$repo

    if [ ! -z "$toxs" ]; then
	rm -f $JJB_DIR/$repo/${repo}-python.yaml

	project=${repo}-java
	echo $repo/${repo}-python.yaml
	
	cat > $JJB_DIR/$repo/${repo}-python.yaml <<EOF
---
- project:
    name: ${repo}-python
    project: '${repo}'
    stream:
      - 'master':
          branch: 'master'
EOF
	if [ $in_sun_branch ]; then
	    cat >> $JJB_DIR/$repo/${repo}-python.yaml <<EOF
      - 'sun':
          branch: 'sun'
EOF
	fi
	cat >> $JJB_DIR/$repo/${repo}-python.yaml <<EOF
    mvn-settings: '${repo}-settings'
    build-node: 'centos7-redis-2c-1g'
    subproject:
EOF
	for tox in $toxs; do
	    toxpath=${tox%/tox.ini}

	    if [ "$toxpath" == "" ]; then
		subproject="root"
		pathparam="."
		pattern="**"
	    else
		subproject=${toxpath////-} # replace slash with dash
		pathparam=$toxpath
		pattern="$toxpath/**"

		# do special subproject names
		for SUB in "${SUBPROJECT_MAP[@]}"; do
		    if [ "${SUB%:*}" = "$repo/$toxpath" ]; then
			subproject=${SUB#*:}
		    fi
		done
	    fi

	    cat >> $JJB_DIR/$repo/${repo}-python.yaml <<EOF
      - '${subproject}':
          path: '${pathparam}'
          pattern: '${pattern}'
EOF
	done
	cat >> $JJB_DIR/$repo/${repo}-python.yaml <<EOF
    jobs:
      - '{project}-{stream}-{subproject}-verify-python'
EOF
    fi




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
    
    
    if [ ! -z "$poms" ]; then
	rm -f $JJB_DIR/$repo/${repo}.yaml
	rm -f $JJB_DIR/$repo/${repo}-java.yaml
	echo $repo/${project}.yaml
    fi

    if [ $has_subprojects -eq 0 ]; then
	# root pom.xml found
	cat > $JJB_DIR/$repo/${project}.yaml <<EOF
---
- project:
    name: ${project}
    jobs:
      - '{project}-{stream}-verify-java'
      - '{project}-{stream}-merge-java'

    project: '${repo}'
    stream:
      - 'master':
          branch: 'master'
EOF
	if [ $in_sun_branch ]; then
	    cat >> $JJB_DIR/$repo/${project}.yaml <<EOF
      - 'sun':
          branch: 'sun'
EOF
	fi
	cat >> $JJB_DIR/$repo/${project}.yaml <<EOF
    mvn-settings: '${repo}-settings'
EOF
    elif [ ! -z "$poms" ]; then
	cat > $JJB_DIR/$repo/${project}.yaml <<EOF
---
- project:
    name: ${project}
    project: '${repo}'
    stream:
      - 'master':
          branch: 'master'
EOF
	if [ $in_sun_branch ]; then
	    cat >> $JJB_DIR/$repo/${project}.yaml <<EOF
      - 'sun':
          branch: 'sun'
EOF
	fi
	cat >> $JJB_DIR/$repo/${project}.yaml <<EOF
    mvn-settings: '${repo}-settings'
    subproject:
EOF

	for pom in $poms; do
	    pompath=${pom%/pom.xml}
	    subproject=${pompath////-} # replace slash with dash
	    cat >> $JJB_DIR/$repo/${project}.yaml <<EOF
      - '${subproject}':
          pom: '${pom}'
          pattern: '${pompath}/**'
EOF
	done

	if [ -e $BUILD_DIR/$repo/pom.xml ]; then
	    cat >> $JJB_DIR/$repo/${project}.yaml <<EOF
      - 'root':
          pom: 'pom.xml'
          pattern: '*'
EOF
	fi

	cat >> $JJB_DIR/$repo/${project}.yaml <<EOF
    jobs:
      - '{project}-{stream}-{subproject}-verify-java'
      - '{project}-{stream}-{subproject}-merge-java'
EOF
    fi
done
