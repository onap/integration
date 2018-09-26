#!/bin/bash
#
# -------------------------------------------------------------------------
#   Copyright (c) 2015-2017 AT&T Intellectual Property
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# -------------------------------------------------------------------------
#

echo "### This is ${WORKSPACE}/test/csit/scripts/optf-has/osdf/simulator_script.sh"
#
# add here whatever commands is needed to prepare the optf/osdf CSIT testing
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

# clone optf-osdf project
git clone https://gerrit.onap.org/r/optf/osdf

#echo "i am ${USER} : only non jenkins users may need proxy settings"
if [ ${USER} != 'jenkins' ]; then

    # add proxy settings into this script when you work behind a proxy
    ${WORKSPACE}/test/csit/scripts/optf-has/osdf/osdf_proxy_settings.sh ${WORK_DIR}

fi

## prepare osdf_sim
#cd ${WORK_DIR}/osdf/test/functest/simulators
#
## check Dockerfile content
#cat ./Dockerfile
#
## build osdf_sim
#./build_sim_image.sh

# run osdf_sim
docker run -d --name osdf_sim -p "5000:5000"  osdf_sim:latest;

OSDF_SIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' osdf_sim`
echo "OSDF_SIM_IP=${OSDF_SIM_IP}"

${WORKSPACE}/test/csit/scripts/optf-has/osdf/wait_for_port.sh ${OSDF_SIM_IP} 5000


# wait a while before continuing
sleep 2

echo "inspect docker things for tracing purpose"
docker inspect osdf_sim

