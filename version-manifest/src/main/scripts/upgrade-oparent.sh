#!/bin/bash
#
# Copyright 2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
cat projects.txt | grep -v oparent | grep -v doc | grep -v ci-management | while read p; do
    pushd $p

    #git fetch origin
    #git reset --hard origin
    for pom in $(find -name pom.xml); do
        git checkout origin/master -- $pom
        dos2unix < $pom | cmp -s - $pom
        IS_DOS=$?
        if grep -q "oparent" $pom; then
            xmlstarlet ed -L -P -N ns="http://maven.apache.org/POM/4.0.0"  -u '/_:project/_:parent[_:groupId="org.onap.oparent" and _:artifactId="oparent"]/_:version' -v '1.2.0' $pom
            sed -i 's/^[ \t]*$//' $pom
        fi
        if grep -q "guava" $pom; then
            xmlstarlet ed -L -P -N ns="http://maven.apache.org/POM/4.0.0"  -d '//_:dependency[_:groupId="com.google.guava" and _:artifactId="guava"]/_:version' $pom
            sed -i 's/^[ \t]*$//' $pom
        fi
        if [ $IS_DOS -ne 0 ]; then
            unix2dos $pom
        fi
    done
    git --no-pager diff


    if [ $(git rev-parse HEAD) == $(git rev-parse @{u}) ]; then

        git commit -a -s -m 'Use managed guava version

Use centrally managed guava version specified in
oparent.  Includes upgrade to oparent 1.2.0.

This change was submitted by script and may include
additional whitespace or formatting changes.

Issue-ID: INT-619
'
    else
        git commit -a -s --amend --no-edit
    fi
    git review -r origin -D
    popd
done
