#!/bin/bash
# 
# ============LICENSE_START=======================================================
# org.onap.dmaap
# ================================================================================
# Copyright (C) 2018 AT&T Intellectual Property. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================
# 
#

#
# starts a mock server container named $1-mock
# and runs init-mock-$1.sh to initialize it
# modifies global var IP to provide the IP address of the started container
function start_mock() {
	IP=""
	app=$1
	port=${2:-1080}
	docker run --name ${app}-mock -d jamesdbloom/mockserver /opt/mockserver/run_mockserver.sh -logLevel INFO -serverPort ${port} -proxyPort 1090
	IP=`get-instance-ip.sh ${app}-mock`

	# Wait for initialization
	for i in {1..10}; do
    	curl -sS ${IP}:${port} && break
    	echo sleep $i
    	sleep $i
	done

	set -x
	${WORKSPACE}/test/csit/scripts/dmaap-buscontroller/init-mock-${app}.sh ${IP}
	set +x

	# this is the output of this function	
	#echo "$IP"
}

