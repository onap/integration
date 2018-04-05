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
# Place the scripts in run order:
# Start all process required for executing test case

#start generic simulator
${WORKSPACE}/test/csit/scripts/so/vcpe/generic_sim/generic_sim_build.sh ${WORKSPACE}/test/csit/scripts/so/vcpe/generic_sim/
${WORKSPACE}/test/csit/scripts/so/vcpe/generic_sim/generic_sim_run.sh
${WORKSPACE}/test/csit/scripts/so/vcpe/vcpe.sh

#start mariadb
docker run -d --name mariadb -h db.mso.testlab.openecomp.org -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 -v ${WORKSPACE}/test/csit/scripts/mariadb/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d  -v ${WORKSPACE}/test/csit/scripts/mariadb/conf.d:/etc/mysql/conf.d nexus3.onap.org:10001/mariadb

#start so
docker run -d --name so -h mso.mso.testlab.openecomp.org -e MYSQL_ROOT_PASSWORD=password --link=mariadb:db.mso.testlab.openecomp.org -p 8080:8080 -v ${WORKSPACE}/test/csit/scripts/so/chef-config:/shared nexus3.onap.org:10001/openecomp/mso:1.1-STAGING-latest


SO_IP=`get-instance-ip.sh so`
# Wait for initialization
for i in {1..10}; do
    curl -sS ${SO_IP}:1080 && break
    echo sleep $i
    sleep $i
done

#REPO_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' so`
REPO_IP='127.0.0.1'
# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v REPO_IP:${REPO_IP}"
