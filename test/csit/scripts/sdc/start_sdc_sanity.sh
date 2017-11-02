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



#start Sanity docker

docker run --detach --name sdc-sanity --env HOST_IP=${IP} --env ENVNAME="${DEP_ENV}" --env http_proxy=${http_proxy} --env https_proxy=${https_proxy} --env no_proxy=${no_proxy} --log-driver=json-file --log-opt max-size=100m --log-opt max-file=10 --ulimit memlock=-1:-1 --memory 1g --memory-swap=1g --ulimit nofile=4096:100000 --volume /etc/localtime:/etc/localtime:ro --volume ${WORKSPACE}/data/logs/sdc-sanity/target:/var/lib/tests/target --volume ${WORKSPACE}/data/logs/sdc-sanity/ExtentReport:/var/lib/tests/ExtentReport --volume ${WORKSPACE}/data/environments:/root/chef-solo/environments --publish 9560:9560 ${PREFIX}/sdc-sanity:${RELEASE}

#echo "please wait while Sanity Docker is starting..."
echo ""
c=60 # seconds to wait
REWRITE="\e[45D\e[1A\e[K"
while [ $c -gt 0 ]; do
    c=$((c-1))
    sleep 1
    echo -e "${REWRITE}$c"
done
echo -e ""


#monitor sanity process 

TIME_OUT=1200
INTERVAL=20
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  
PID=`docker exec -i sdc-sanity ps -ef | grep java | awk '{print $2}'`
echo sanity PID is -- $PID
  
if [ -z "$PID" ]
 then
    echo SDC sanity finished in $TIME seconds
    break
  fi

  echo Sleep: $INTERVAL seconds before testing if SDC sanity completed. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]
 then
   echo TIME OUT: Sany was NOT completed in $TIME_OUT seconds... Could cause problems for tests...
fi
cp -rf ${WORKSPACE}/data/logs/sdc-sanity/ExtentReport/* ${WORKSPACE}/archives/
cp -rf ${WORKSPACE}/data/logs/ ${WORKSPACE}/archives/ 
cp -rf ${WORKSPACE}/data/logs/sdc-sanity/target/*.xml ${WORKSPACE}/archives/ 

