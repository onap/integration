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
# These scripts are sourced by run-csit.sh.

source ${SCRIPTS}/common_functions.sh

# Start MSB
${SCRIPTS}/common-services-microservice-bus/startup.sh i-msb
MSB_IP=`get-instance-ip.sh i-msb`
curl_path='http://'${MSB_IP}'/openoui/microservices/index.html'
sleep_msg="Waiting_connection_for_url_for:i-msb"
wait_curl_driver CURL_COMMAND=$curl_path WAIT_MESSAGE='"$sleep_msg"' GREP_STRING="org_openo_msb_route_title" REPEAT_NUMBER="15"


#Start market place
docker run -d -i -t --name=marketplace -e MSB_ADDR=$MSB_IP  -p 8702:8702 openoint/vnf-sdk-marketplace

# Start vnfsdk
docker run -d -i -t --name=functest -e MSB_ADDR=$MSB_IP  -p 8701:8701 openoint/vnfsdk-function-test

#Start catalogue, aria
docker run -d -i -t --name=catalog -e  MSB_ADDR=$MSB_IP  -p 8200:8200 -p 8201:8201 openoint/common-tosca-catalog

docker run -d -i -t  --name=aria -e  MSB_ADDR=$MSB_IP  -p 8204:8204  openoint/common-tosca-aria



echo SCRIPTS

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IP:${MSB_IP}  -v SCRIPTS:${SCRIPTS}"

# Run Mock server
run_robottestlib