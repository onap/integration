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
echo "### This is ${WORKSPACE}/test/csit/scripts/optf-has/has/simulator_script.sh"
#
# add here whatever commands is needed to prepare the optf/has CSIT testing
#

# assume the base is /tmp dir
DIR=/tmp

# the directory of the script
echo ${DIR}
cd ${DIR}

# the temp directory used, within $DIR
# omit the -p parameter to create a temporal directory in the default location
WORK_DIR=`mktemp -d -p "$DIR"`
echo ${WORK_DIR}
cd ${WORK_DIR}

# clone optf-has project
git clone https://gerrit.onap.org/r/optf/has

#echo "i am ${USER} : only non jenkins users may need proxy settings"
if [ ${USER} != 'jenkins' ]; then

    # add proxy settings into this script when you work behind a proxy
    ${WORKSPACE}/test/csit/scripts/optf-has/has/has_proxy_settings.sh ${WORK_DIR}

fi

# prepare aaisim
cd ${WORK_DIR}/has/conductor/conductor/tests/functional/simulators/aaisim/

# check Dockerfile content
cat ./Dockerfile

# build aaisim
docker build -t aaisim .  

# run aaisim
docker run -d --name aaisim -p 8081:8081  aaisim

AAISIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' aaisim`
echo "AAISIM_IP=${AAISIM_IP}"

${WORKSPACE}/test/csit/scripts/optf-has/has/wait_for_port.sh ${AAISIM_IP} 8081

# prepare multicloudsim
cd ${WORK_DIR}/has/conductor/conductor/tests/functional/simulators/multicloudsim/

# check Dockerfile content
cat ./Dockerfile

# build multicloudsim
docker build -t multicloudsim .

# run multicloudsim
docker run -d --name multicloudsim -p 8082:8082  multicloudsim

MULTICLOUDSIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' multicloudsim`
echo "MULTICLOUDSIM_IP=${MULTICLOUDSIM_IP}"

${WORKSPACE}/test/csit/scripts/optf-has/has/wait_for_port.sh ${MULTICLOUDSIM_IP} 8082

# wait a while before continuing
sleep 2

#echo "inspect docker things for tracing purpose"
#docker inspect aaisim
#docker inspect multicloudsim
