#!/bin/bash

source ${SCRIPTS}/common_functions.sh

export PRH_SERVICE="prh"
export DMAAP_SIMULATOR="dmaap_simulator"

cd ${WORKSPACE}/test/csit/tests/dcaegen2/prh_testcases/resources/

docker login -u docker -p docker nexus3.onap.org:10003
docker-compose up -d

# Wait for initialization of Docker containers
for i in {1..50}; do
	if [ $(docker inspect --format '{{ .State.Running }}' ${PRH_SERVICE}) ] && \
	  [ $(docker inspect --format '{{ .State.Running }}' ${DMAAP_SIMULATOR}) ]
	then
		echo "dmaap_simulator and prh services are running"
		break    		
	else 
		echo sleep ${i}
		sleep ${i}
	fi
done

PRH_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${PRH_SERVICE})
DMAAP_SIMULATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DMAAP_SIMULATOR})

bypass_ip_adress ${PRH_IP}
bypass_ip_adress ${DMAAP_SIMULATOR_IP}

echo PRH_IP=${PRH_IP}
echo DMAAP_SIMULATOR_IP=${DMAAP_SIMULATOR_IP}

# Wait for initialization of docker services
for i in {1..50}; do
    curl -sS -m 1 localhost:2222 && \
    curl -sS -m 1 localhost:8100/heartbeat && break
    echo sleep ${i}
    sleep ${i}
done

#
docker cp prh:/config/prh_endpoints.json ${WORKDIR}
sed -i -e 's/"dmaapHostName":.*/"dmaapHostName": "'${DMAAP_SIMULATOR_IP}'",/g' ${WORKDIR}/prh_endpoints.json
sed -i -e 's/"aaiHost":.*/"aaiHost": "'${DMAAP_SIMULATOR_IP}'",/g' ${WORKDIR}/prh_endpoints.json
docker cp ${WORKDIR}/prh_endpoints.json prh:/config/

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DMAAP_SIMULATOR:localhost:2222 -v PRH:localhost:8100"
