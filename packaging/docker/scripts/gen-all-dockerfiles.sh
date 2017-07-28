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
# $1 autorelease build

if [ -z "$1" ]; then
    BUILD="snapshots"
else
    BUILD=$1
fi

VERSION="1.1.0-SNAPSHOT"

# docker root dir
ROOT=`git rev-parse --show-toplevel`/test/csit/docker

cd $ROOT
for dirsrc in `$ROOT/scripts/ls-microservices.py | sort`; do
    $ROOT/scripts/gen-dockerfiles.sh $dirsrc $BUILD &
done
wait


mkdir -p $ROOT/target
cat > $ROOT/target/pom.xml <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.openo.integration.docker</groupId>
  <artifactId>docker-root</artifactId>
  <version>${VERSION}</version>
  <packaging>pom</packaging>
  <build>
    <plugins>
      <plugin>
        <groupId>io.fabric8</groupId>
        <artifactId>docker-maven-plugin</artifactId>
        <version>0.19.0</version>
        <extensions>true</extensions>
      </plugin>
    </plugins>
  </build>
  <modules>
EOF
for dirsrc in `$ROOT/scripts/ls-microservices.py | sort`; do
cat >> $ROOT/target/pom.xml <<EOF
    <module>../${dirsrc}/target</module>
EOF
done
cat >> $ROOT/target/pom.xml <<EOF
  </modules>
</project>
EOF
