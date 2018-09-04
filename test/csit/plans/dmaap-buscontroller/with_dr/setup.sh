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

source ${SCRIPTS}/common_functions.sh


if [ "$USE_EXISTING_DMAAP" = "Y" ]
then
	ROBOT_VARIABLES="-v AAF_IP:0.0.0 -v MRC_IP:0.0.0.0 -v DRPS_IP:172.17.0.3 -v DMAAPBC_IP:172.17.0.4"
else

	# Place the scripts in run order:
	source ${WORKSPACE}/test/csit/scripts/dmaap-buscontroller/dr-launch.sh
	dmaap_dr_launch
	DRPS_IP=${IP}

	#source ${WORKSPACE}/test/csit/scripts/dmaap-buscontroller/start-mock.sh
	#start_mock "aaf" 
	#AAF_IP=${IP}
	AAF_IP=0.0.0.0
	#start_mock "drps" 
	#DRPS_IP=${IP}
	MRC_IP=0.0.0.0

	source ${WORKSPACE}/test/csit/scripts/dmaap-buscontroller/dmaapbc-launch.sh 
	dmaapbc_launch $AAF_IP $MRC_IP $DRPS_IP
	DMAAPBC_IP=${IP}


	echo "AAF_IP=$AAF_IP MRC_IP=$MRC_IP DRPS_IP=$DRPS_IP DMAAPBC_IP=$DMAAPBC_IP"

	# Pass any variables required by Robot test suites in ROBOT_VARIABLES
	ROBOT_VARIABLES="-v AAF_IP:${AAF_IP} -v MRC_IP:${MRC_IP} -v DRPS_IP:${DRPS_IP} -v DMAAPBC_IP:${DMAAPBC_IP}"
	set -x
	${WORKSPACE}/test/csit/scripts/dmaap-buscontroller/dmaapbc-init.sh ${DMAAPBC_IP} ${DRPS_IP} ${MRC_IP} https
	set +x
fi

