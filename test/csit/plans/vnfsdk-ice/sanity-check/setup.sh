#!/bin/bash
#
# Copyright 2018 Orange Labs.
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


#Start ice server
docker run --rm --name vnfsdk-ice -d -p 5000:5000 nexus3.onap.org:10001/onap/vnfsdk/ice:latest

# Wait for server initialization
echo Wait for vnfsdk-ice initialization
until [ "`/usr/bin/docker inspect -f {{.State.Running}} vnfsdk-ice`"=="true" ]; do
	    sleep 1;
done;
ICE_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' vnfsdk-ice`


# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS} -v ICE_IP:${ICE_IP}"
echo ${ROBOT_VARIABLES}

