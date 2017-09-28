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

git clone http://gerrit.onap.org/r/policy/docker
cd docker

${WORK_DIR}/maven/apache-maven-3.3.9/bin/mvn clean install prepare-package --settings ../oparent/settings.xml
cp policy-pe/* target/policy-pe
cp policy-drools/* target/policy-drools

docker build -t onap/policy/policy-os     policy-os
docker build -t onap/policy/policy-db     policy-db
docker build -t onap/policy/policy-nexus  policy-nexus
docker build -t onap/policy/policy-base   policy-base
docker build -t onap/policy/policy-pe     target/policy-pe
docker build -t onap/policy/policy-drools target/policy-drools

chmod +x config/drools/drools-tweaks.sh

echo $IP > config/pe/ip_addr.txt
ls -l config/pe/ip_addr.txt
cat config/pe/ip_addr.txt

export MTU=9126

docker-compose -f docker-compose-integration.yml up -d 

docker ps

docker inspect drools

POLICY_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' drools`
echo ${POLICY_IP}

sleep 3m

docker inspect pdp

PDP_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' pdp`
echo ${PDP_IP}

sleep 3m

#for i in {1..60}; do
TIME_OUT=6000
INTERVAL=20 
TIME=0 
while [ "$TIME" -lt "$TIME_OUT" ]; do 
    curl -i --user healthcheck:zb!XztG34 -H "ContentType: application/json" -H "Accept: application/json" ${POLICY_IP}:6969/healthcheck && break
    echo sleep $i
    sleep $i
	
echo Sleep: $INTERVAL seconds before testing if Policy is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds 
  sleep $INTERVAL 
  TIME=$(($TIME+$INTERVAL))
	
done

#curl -v --silent -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'ClientAuth: cHl0aG9uOnRlc3Q=' -H 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' -H 'Environment: TEST' -X POST -d '{"policyName": "*.*"}'

TIME_OUT=6000
INTERVAL=20 
TIME=0 
while [ "$TIME" -lt "$TIME_OUT" ]; do 
	
	curl -v --silent -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'ClientAuth: cHl0aG9uOnRlc3Q=' -H 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' -H 'Environment: TEST' -X POST -d '{"policyName": "*.*"}' http://${PDP_IP}:8081/pdp/api/getConfig && break
    echo sleep $i
    sleep $i
	
echo Sleep: $INTERVAL seconds before testing if Policy is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds 
  sleep $INTERVAL 
  TIME=$(($TIME+$INTERVAL))
	
done

