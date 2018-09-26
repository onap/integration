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

echo "### This is ${WORKSPACE}/test/csit/scripts/optf-has/osdf/osdf_script.sh"
#
# add here whatever commands is needed to prepare the optf/osdf CSIT testing
#

# assume the base is /tmp dir
DIR=/tmp

# the directory of the script
echo ${DIR}
cd ${DIR}

# create directory for volume and copy configuration file
# run docker containers
OSDF_CONF=/tmp/osdf/properties/osdf_config.yaml
COMMON_CONF=/tmp/osdf/properties/common_config.yaml
IMAGE_NAME=nexus3.onap.org:10001/onap/optf-osdf
IMAGE_VER=latest

mkdir -p /tmp/osdf/properties

cp ${WORKSPACE}/test/csit/scripts/optf-has/osdf/osdf-properties/*.yaml /tmp/osdf/properties/.

#chmod -R 777 /tmp/conductor/properties

#change conductor/configdb simulator urls
OSDF_SIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' osdf_sim`
echo "OSDF_SIM_IP=${OSDF_SIM_IP}"

sed  -i -e "s%127.0.0.1:5000%${OSDF_SIM_IP}:5000%g" $OSDF_CONF

docker run -d --name optf-osdf -v ${OSDF_CONF}:/osdf/config/osdf_config.yaml -v ${COMMON_CONF}:/osdf/config/common_config.yaml -p "8698:8699" ${IMAGE_NAME}:${IMAGE_VER}

sleep 20

OSDF_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' optf-osdf`
${WORKSPACE}/test/csit/scripts/optf-has/osdf/wait_for_port.sh ${OSDF_IP} 8699

echo "inspect docker things for tracing purpose"
docker inspect optf-osdf
