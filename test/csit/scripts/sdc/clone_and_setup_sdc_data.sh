#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CLAMP
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#

echo "This is ${WORKSPACE}/test/csit/scripts/sdc/clone_and_setup_sdc_data.sh"

# Clone sdc enviroment template 
mkdir -p ${WORKSPACE}/data/environments/
mkdir -p ${WORKSPACE}/data/clone/
mkdir -p ${WORKSPACE}/data/logs/BE/SDC/SDC-BE
mkdir -p ${WORKSPACE}/data/logs/FE/SDC/SDC-FE
chmod -R 777 ${WORKSPACE}/data/logs


cd ${WORKSPACE}/data/clone
git clone --depth 1 http://gerrit.onap.org/r/sdc -b master

chmod -R 775 ${WORKSPACE}/data/

# set enviroment variables

export ENV_NAME='CSIT'
export MR_IP_ADDR='10.0.0.1'

ifconfig

#if [ -e /opt/config/public_ip.txt ]
#  then
#    IP_ADDRESS=$(cat /opt/config/public_ip.txt)
#   else
#    IP_ADDRESS=$(ifconfig ens3 | grep "inet addr" | tr -s ' ' | cut -d' ' -f3 | cut -d':' -f2)
#   fi

IP_ADDRESS=`ip route get 8.8.8.8 | awk '/src/{ print $7 }'`
export HOST_IP=$IP_ADDRESS

   
  cat ${WORKSPACE}/data/clone/sdc/sdc-os-chef/environments/Template.json | sed "s/yyy/"$IP_ADDRESS"/g" > ${WORKSPACE}/data/environments/$ENV_NAME.json
  sed -i "s/xxx/"$ENV_NAME"/g" ${WORKSPACE}/data/environments/$ENV_NAME.json
  sed -i "s/\"ueb_url_list\":.*/\"ueb_url_list\": \""$MR_IP_ADDR","$MR_IP_ADDR"\",/g" ${WORKSPACE}/data/environments/$ENV_NAME.json
  sed -i "s/\"fqdn\":.*/\"fqdn\": [\""$MR_IP_ADDR"\", \""$MR_IP_ADDR"\"]/g" ${WORKSPACE}/data/environments/$ENV_NAME.json


