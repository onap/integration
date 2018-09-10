#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2018 Ericsson. All rights reserved.
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
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

docker run -d --name apex -p 12561:12561 -p 23324:23324 -it nexus3.onap.org:10001/onap/policy-apex-pdp:2.0-SNAPSHOT-latest /bin/bash -c "/opt/app/policy/apex-pdp/bin/apexEngine.sh -c /opt/app/policy/apex-pdp/examples/config/SampleDomain/RESTServerJsonEvent.json"

APEX_IP=`get-instance-ip.sh apex`
echo APEX IP IS ${APEX_IP}
Wait for initialization
for i in {1..10}; do
   curl -sS ${APEX_IP}:23324 && break
   echo sleep $i
   sleep $i
done
