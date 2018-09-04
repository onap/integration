
#!/bin/bash

#!/bin/bash

# script to launch DMaaP DR  docker containers
# sets global var IP with assigned IP address of DR Prov

function dmaap_dr_launch() {
        IP=""


	# This next section was copied from scripts/dmaap-datarouter/dr-suite/setup.sh
	# and slightly modified...

	# Clone DMaaP Data Router repo
	mkdir -p $WORKSPACE/archives/dmaapdr
	cd $WORKSPACE/archives/dmaapdr

	git clone --depth 1 https://gerrit.onap.org/r/dmaap/datarouter -b master
	cd datarouter
	git pull
	cd $WORKSPACE/archives/dmaapdr/datarouter/docker-compose/

	sed -i 's/10003/10001/g' docker-compose.yml
	# start DMaaP DR containers with docker compose and configuration from docker-compose.yml
	docker login -u docker -p docker nexus3.onap.org:10001
	docker-compose up -d

	# Wait for initialization of Docker container for datarouter-node, datarouter-prov and mariadb
	for i in {1..50}; do
	    if [ $(docker inspect --format '{{ .State.Running }}' datarouter-node) ] && \
		[ $(docker inspect --format '{{ .State.Running }}' datarouter-prov) ] && \
		[ $(docker inspect --format '{{ .State.Running }}' mariadb) ]
	    then
		echo "DR Service Running"
		break
	    else
		echo sleep $i
		sleep $i
	    fi
	done

	DR_PROV_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-prov)
	DR_NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-node)
	DR_GATEWAY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' datarouter-prov)

	echo DR_PROV_IP=${DR_PROV_IP}
	echo DR_NODE_IP=${DR_NODE_IP}
	echo DR_GATEWAY_IP=${DR_GATEWAY_IP}

	docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/NODES?val=dmaap-dr-node\|$DR_GATEWAY_IP"
	docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"

	#Pass any variables required by Robot test suites in ROBOT_VARIABLES
	ROBOT_VARIABLES="-v DR_PROV_IP:${DR_PROV_IP} -v DR_NODE_IP:${DR_NODE_IP}"

        IP=${DR_GATEWAY_IP}
}
