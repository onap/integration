#!/bin/bash

source ${SCRIPTS}/common_functions.sh

HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
export HOST_IP=${HOST_IP}

export PRH_SERVICE="prh"
export DMAAP_SIMULATOR="dmaap_simulator"
export AAI_SIMULATOR="aai_simulator"

cd ${WORKSPACE}/test/csit/tests/dcaegen2/prh-testcases/resources/

docker-compose up -d --build

# Wait for initialization of Docker containers
for i in {1..10}; do
	if [ $(docker inspect --format '{{ .State.Running }}' ${PRH_SERVICE}) ] && \
	  [ $(docker inspect --format '{{ .State.Running }}' ${DMAAP_SIMULATOR}) ] && \
	  [ $(docker inspect --format '{{ .State.Running }}' ${AAI_SIMULATOR}) ]
	then
		echo "dmaap_simulator, aai_simulator and prh services are running"
		break    		
	else 
		echo sleep ${i}
		sleep ${i}
	fi
done

PRH_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${PRH_SERVICE})
DMAAP_SIMULATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DMAAP_SIMULATOR})
AAI_SIMULATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${AAI_SIMULATOR})

bypass_ip_adress ${PRH_IP}
bypass_ip_adress ${DMAAP_SIMULATOR_IP}
bypass_ip_adress ${AAI_SIMULATOR_IP}


echo PRH_IP=${PRH_IP}
echo DMAAP_SIMULATOR_IP=${DMAAP_SIMULATOR_IP}
echo AAI_SIMULATOR_IP=${AAI_SIMULATOR_IP}

# Wait for initialization of docker services
for i in {1..10}; do
    curl -sS -m 1 localhost:2222 && \
    curl -sS -m 1 localhost:3333 && \
    curl -sS -m 1 localhost:8100/heartbeat && break
    echo sleep ${i}
    sleep ${i}
done

docker cp prh:/config/prh_endpoints.json ${WORKDIR}
sed -i -e 's/"dmaapHostName":.*/"dmaapHostName": "'${DMAAP_SIMULATOR_IP}'",/g' ${WORKDIR}/prh_endpoints.json
sed -i -e 's/"aaiHost":.*/"aaiHost": "'${AAI_SIMULATOR_IP}'",/g' ${WORKDIR}/prh_endpoints.json
docker cp ${WORKDIR}/prh_endpoints.json prh:/config/

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DMAAP_SIMULATOR:localhost:2222 -v AAI_SIMULATOR:localhost:3333 -v PRH:localhost:8100"

pip install docker==2.7.0
