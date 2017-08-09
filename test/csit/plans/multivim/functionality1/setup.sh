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

# start multivim-broker
run-instance.sh openoint/multivim-broker multivim-broker  " -i -t -e MSB_ADDR=${MSB_IP}:80"
extsys_ip=`get-instance-ip.sh multivim-broker`
sleep_msg="Waiting_for_multivim-broker"
curl_path='http://'${MSB_IP}':80/openoapi/multivim/v1/swagger.json'
wait_curl_driver CURL_COMMAND=$curl_path WAIT_MESSAGE='"$sleep_msg"' REPEAT_NUMBER=25 GREP_STRING="swagger"

echo SCRIPTS
# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IP:${MSB_IP}  -v SCRIPTS:${SCRIPTS}"



