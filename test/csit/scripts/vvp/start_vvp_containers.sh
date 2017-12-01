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

echo "This is ${WORKSPACE}/test/csit/scripts/vvp/start_vvp_containers.sh"

export IP=$HOST_IP
export PREFIX='nexus3.onap.org:10001/openecomp/vvp'
export RELEASE='latest'

#start Engagement Manager pod:
docker run \
--detach \
--entrypoint="" \
--name vvp-engagementmgr \
--env-file ${WORKSPACE}/data/environments/vvp_env.list \
--log-driver=json-file \
--log-opt max-size=100m \
--log-opt max-file=10 \
--ulimit memlock=-1:-1 \
--memory 4g \
--memory-swap=4g \
--ulimit nofile=4096:100000 \
--volume /etc/localtime:/etc/localtime:ro \
--volume /opt/configmaps/settings:/opt/configmaps/settings/ \
--publish 9090:80 ${PREFIX}/engagementmgr:${RELEASE}

docker cp /opt/configmaps/settings/uwsgi.ini vvp-engagementmgr:/srv/vvp/settings/

echo "please wait while Engagement Manager is starting..."
echo ""
c=60 # seconds to wait
REWRITE="\e[25D\e[1A\e[K"
while [ $c -gt 0 ]; do
    c=$((c-1))
    sleep 1
    echo -e "${REWRITE}$c"
done
echo -e ""

#run migration again:
docker exec -d vvp-engagementmgr sh -c "python3 /srv/manage.py migrate"

#run initial populate db again:
docker exec -d vvp-engagementmgr sh -c "python3 /srv/manage.py initial_populate_db"


echo "Will copy the generated DB sqlite3 file into the application directory in 30 seconds..."
sleep 30
#copy the generated DB sqlite3 file into the application directory:
docker exec -d vvp-engagementmgr sh -c "cp emdb.db /srv/emdb.db -f"

TIME_OUT=600
INTERVAL=5
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost:9090/vvp/v1/engmgr/vendors); echo $response

  if [ "$response" == "200" ]; then
    echo VVP-Engagement-Manager well started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if VVP-Engagement-Manager is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for tests...
else
   echo "Done starting vvp containers!"
fi
