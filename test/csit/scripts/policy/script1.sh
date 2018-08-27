#!/bin/bash
#
# Copyright 2017 AT&T Intellectual Property. All rights reserved.
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
echo "This is ${WORKSPACE}/test/csit/scripts/policy/script1.sh"


# the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ${DIR}

# the temp directory used, within $DIR
# omit the -p parameter to create a temporal directory in the default location
WORK_DIR=`mktemp -d -p "$DIR"`
echo ${WORK_DIR}

cd ${WORK_DIR}

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# bring down maven
mkdir maven
cd maven
curl -O http://apache.claz.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar -xzvf apache-maven-3.3.9-bin.tar.gz
ls -l
export PATH=${PATH}:${WORK_DIR}/maven/apache-maven-3.3.9/bin
${WORK_DIR}/maven/apache-maven-3.3.9/bin/mvn -v
cd ..

ifconfig

if ! ifconfig eth0; then
	if ! ifconfig ens3; then
		echo "Could not determine IP address"
		exit 1
	fi
	export IP=`ifconfig ens3 | awk -F: '/inet addr/ {gsub(/ .*/,"",$2); print $2}'`
else
	export IP=`ifconfig eth0 | awk -F: '/inet addr/ {gsub(/ .*/,"",$2); print $2}'`
fi
echo $IP

if ! ifconfig docker0; then
	if ! ifconfig ens3; then
		echo "Could not determine IP address"
		exit 1
	fi
	export DOCKER_IP_IP=`ifconfig ens3 | awk -F: '/inet addr/ {gsub(/ .*/,"",$2); print $2}'`
else
	export DOCKER_IP=`ifconfig docker0 | awk -F: '/inet addr/ {gsub(/ .*/,"",$2); print $2}'`
fi
echo $DOCKER_IP

git clone http://gerrit.onap.org/r/oparent

git clone http://gerrit.onap.org/r/policy/engine
cd engine/packages/docker 
${WORK_DIR}/maven/apache-maven-3.3.9/bin/mvn prepare-package --settings ${WORK_DIR}/oparent/settings.xml
docker build -t onap/policy-pe target/policy-pe

cd ${WORK_DIR}
git clone http://gerrit.onap.org/r/policy/drools-pdp
cd drools-pdp/packages/docker 
${WORK_DIR}/maven/apache-maven-3.3.9/bin/mvn prepare-package --settings ${WORK_DIR}/oparent/settings.xml
docker build -t onap/policy-drools target/policy-drools

cd ${WORK_DIR}
git clone http://gerrit.onap.org/r/policy/docker
cd docker

chmod +x config/drools/drools-tweaks.sh

echo $IP > config/pe/ip_addr.txt
ls -l config/pe/ip_addr.txt
cat config/pe/ip_addr.txt

export MTU=9126

export PRELOAD_POLICIES=false
docker-compose -f docker-compose-integration.yml up -d 

if [ ! $? -eq 0 ]; then
	echo "Docker compose failed"
	exit 1
fi 

docker ps

POLICY_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' drools`
echo ${POLICY_IP}

PDP_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' pdp`
echo ${PDP_IP}

PAP_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' pap`
echo ${PAP_IP}

BRMS_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' brmsgw`
echo ${BRMS_IP}

NEXUS_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' nexus`
echo ${NEXUS_IP}

MARIADB_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' mariadb`
echo ${MARIADB_IP}

sleep 5m

netstat -tnl

docker logs mariadb
${DIR}/wait_for_port.sh ${MARIADB_IP} 3306

docker logs pap
${DIR}/wait_for_port.sh ${PAP_IP} 9091

docker logs pdp
${DIR}/wait_for_port.sh ${PDP_IP} 8081

docker logs brmsgw
${DIR}/wait_for_port.sh ${BRMS_IP} 9989

docker logs nexus
${DIR}/wait_for_port.sh ${NEXUS_IP} 8081

docker logs drools
${DIR}/wait_for_port.sh ${POLICY_IP} 6969

TIME_OUT=600
INTERVAL=20 
TIME=0 
while [ "$TIME" -lt "$TIME_OUT" ]; do 
    curl -i --user healthcheck:zb!XztG34 -H "ContentType: application/json" -H "Accept: application/json" ${POLICY_IP}:6969/healthcheck && break
	
  echo Sleep: $INTERVAL seconds before testing if Policy is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds 
  sleep $INTERVAL 
  TIME=$(($TIME+$INTERVAL))
	
done

TIME_OUT=600
INTERVAL=20 
TIME=0 
while [ "$TIME" -lt "$TIME_OUT" ]; do 
	
	curl -k -i -v -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'ClientAuth: cHl0aG9uOnRlc3Q=' -H 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' -H 'Environment: TEST' -X POST -d '{"policyName": ".*"}' https://${PDP_IP}:8081/pdp/api/getConfig && break
	
echo Sleep: $INTERVAL seconds before testing if Policy is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds 
  sleep $INTERVAL 
  TIME=$(($TIME+$INTERVAL))
	
done

#
# Add more sleep for everything to settle
#
sleep 3m
