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
echo "### This is ${WORKSPACE}/test/csit/scripts/optf/has/has_script.sh"
#
# add here whatever commands is needed to prepare the optf/has CSIT testing
#

# assume the base is /opt
DIR=/opt
#cd /opt

# the directory of the script
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ${DIR}
cd ${DIR}

# the temp directory used, within $DIR
# omit the -p parameter to create a temporal directory in the default location
WORK_DIR=`mktemp -d -p "$DIR"`
echo ${WORK_DIR}

cd ${WORK_DIR}

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi


git clone https://gerrit.onap.org/r/optf/has
cd has
cd conductor/docker

sed  -i -e "s%FROM python:2\.7%FROM python:2\.7\\nENV http_proxy http:\/\/one\.proxy\.att\.com:8080\\nENV https_proxy http:\/\/one\.proxy\.att\.com:8080%g" api/Dockerfile
sed  -i -e "s%FROM python:2\.7%FROM python:2\.7\\nENV http_proxy http:\/\/one\.proxy\.att\.com:8080\\nENV https_proxy http:\/\/one\.proxy\.att\.com:8080%g" controller/Dockerfile
sed  -i -e "s%FROM python:2\.7%FROM python:2\.7\\nENV http_proxy http:\/\/one\.proxy\.att\.com:8080\\nENV https_proxy http:\/\/one\.proxy\.att\.com:8080%g" data/Dockerfile
sed  -i -e "s%FROM python:2\.7%FROM python:2\.7\\nENV http_proxy http:\/\/one\.proxy\.att\.com:8080\\nENV https_proxy http:\/\/one\.proxy\.att\.com:8080%g" reservation/Dockerfile
sed  -i -e "s%FROM python:2\.7%FROM python:2\.7\\nENV http_proxy http:\/\/one\.proxy\.att\.com:8080\\nENV https_proxy http:\/\/one\.proxy\.att\.com:8080%g" solver/Dockerfile


# ./build-dockers.sh
docker build -t api api/
docker build -t controller controller/
docker build -t data data/
docker build -t solver solver/
docker build -t reservation reservation/


# create directory for volume and copy configuration file
mkdir -p /tmp/conductor/properties
cp ${WORKSPACE}/test/csit/scripts/optf/has/has-properties/conductor.conf.onap /tmp/conductor/properties/conductor.conf
cp ${WORKSPACE}/test/csit/scripts/optf/has/has-properties/cert.cer /tmp/conductor/properties/cert.cer
cp ${WORKSPACE}/test/csit/scripts/optf/has/has-properties/cert.key /tmp/conductor/properties/cert.key



# run docker containers
#docker run -d --name cond-data -v /tmp/conductor/properties/conductor.conf:/usr/local/bin/conductor.conf -v /tmp/conductor/properties/cert.key:/usr/local/bin/cert.key -v /tmp/conductor/properties/cert.cer:/usr/local/bin/cert.cer data
#docker run -d --name cond-data -v /tmp/conductor/properties/conductor.conf:/usr/local/bin/conductor.conf data
docker run -d --name cond-cont -v /tmp/conductor/properties/conductor.conf:/usr/local/bin/conductor.conf controller
docker run -d --name cond-api -p 8091:8091  -v /tmp/conductor/properties/conductor.conf:/usr/local/bin/conductor.conf api
docker run -d --name cond-solv -v /tmp/conductor/properties/conductor.conf:/usr/local/bin/conductor.conf solver
docker run -d --name cond-resv -v /tmp/conductor/properties/conductor.conf:/usr/local/bin/conductor.conf reservation

# wait a while before continuing
sleep 30
