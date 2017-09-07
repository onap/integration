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

source ${SCRIPTS}/common_functions.sh

#Start gso
#run-instance.sh openoint/gso-service-manager gso " -i -t -e MSB_ADDR=${MSB_IP}:80 -e MYSQL_ADDR=${INV_ADDR}:3306"
#sleep_msg="Waiting_for_so"
#curl_path='http://'${MSB_IP}':80/api/so/v1/services'
#wait_curl_driver CURL_COMMAND=$curl_path WAIT_MESSAGE='"$sleep_msg"' REPEAT_NUMBER=25 GREP_STRING="\["

#run simulator
#docker run -d -i -t --name gso_csit_simulator -e SIMULATOR_JSON=Stubs/testcase/so/main.json -p 18009:18009 -p 18008:18008  openoint/simulate-test-docker
#SIMULATOR_IP=`get-instance-ip.sh gso_csit_simulator`
#sleep_msg="Waiting_for_simulator"
#curl_path='http://'${SIMULATOR_IP}':18009/api/extsys/v1/vims'
#wait_curl_driver CURL_COMMAND=$curl_path WAIT_MESSAGE='"$sleep_msg"' REPEAT_NUMBER=16 GREP_STRING="\["


#ROBOT_VARIABLES="-v MSB_IP:${MSB_IP}  -v SCRIPTS:${SCRIPTS}  -v SIMULATOR_IP:${SIMULATOR_IP}"
#robot ${ROBOT_VARIABLES} ${SCRIPTS}/../tests/so/sanity-check/register_simulator_to_msb.robot

#start so
docker run -d -t --name so -p 8080:8080 nexus3.onap.org:10001/openecomp/mso

ROBOT_VARIABLES="-v MOCK_IP:${MOCK_IP}"
