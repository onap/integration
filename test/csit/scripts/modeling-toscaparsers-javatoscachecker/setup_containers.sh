#!/bin/bash
#
# ============LICENSE_START=======================================================
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

echo "This is ${WORKSPACE}/test/csit/scripts/modeling-toscaparsers-javatoscachecker/setup_containers.sh"

#start docker image
run-instance.sh nexus3.onap.org:10001/onap/modeling/javatoscachecker:latest modeling_javatoscachecker_1 "-p 8080:8080"

#checker docker image is accesible: picked from clamp, some common script would be good
TIME_OUT=1200
INTERVAL=5
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost:8080/check_template/test_me); echo $response

  if [ "$response" == "404" ]; then
    echo javatoscachecker service started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if javatoscachecker service is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for tests...
fi


