#!/bin/bash
# Place the scripts in run order:
#Make sure python-uuid is installed

# Place the scripts in run order:
source ${SCRIPTS}/dcae-bulkpm/xNFSimulator.sh

# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

# Clone DMaaP Data Router repo
mkdir -p $WORKSPACE/archives/dmaapdr
cd $WORKSPACE/archives/dmaapdr

git clone --depth 1 https://gerrit.onap.org/r/dmaap/datarouter -b master
cd datarouter
git pull
cd $WORKSPACE/archives/dmaapdr/datarouter/docker-compose/

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

#Add the DR_NODE_IP to /etc/hosts
echo "${DR_NODE_IP} dmaap-dr-node" >> /etc/hosts
echo "${DR_PROV_IP} dmaap-dr-prov" >> /etc/hosts

echo DR_PROV_IP=${DR_PROV_IP}
echo DR_NODE_IP=${DR_NODE_IP}
echo DR_GATEWAY_IP=${DR_GATEWAY_IP}

docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/NODES?val=dmaap-dr-node\|$DR_GATEWAY_IP"
docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"

# Start DCAE VES Collector
cd $WORKSPACE/
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
VESC_IMAGE=nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.ves.vescollector:1.3.1
echo VESC_IMAGE=${VESC_IMAGE}

docker run -d  --name vesc -e DMAAPHOST=${HOST_IP} ${VESC_IMAGE}
VESC_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vesc)

# Clone DMaaP Message Router repo
mkdir -p $WORKSPACE/archives/dmaapmr
cd $WORKSPACE/archives/dmaapmr
git clone --depth 1 http://gerrit.onap.org/r/dmaap/messagerouter/messageservice -b master
git pull
cd $WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose
cp $WORKSPACE/archives/dmaapmr/messageservice/bundleconfig-local/etc/appprops/MsgRtrApi.properties /var/tmp/

# start DMaaP MR containers with docker compose and configuration from docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d

ZOOKEEPER=$(docker ps -a -q --filter="name=zookeeper_1")
KAFKA=$(docker ps -a -q --filter="name=kafka_1")
DMAAP=$(docker ps -a -q --filter="name=dmaap_1")

# Wait for initialization of Docker contaienr for DMaaP MR, Kafka and Zookeeper
for i in {1..50}; do
if [ $(docker inspect --format '{{ .State.Running }}' $KAFKA) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $ZOOKEEPER) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $DMAAP) ]
then
   echo "DMaaP Service Running"
   break
else
   echo sleep $i
   sleep $i
fi
done

# Get IP address of DMAAP, KAFKA, Zookeeper
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DMAAP)
KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $KAFKA)
ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ZOOKEEPER)

echo DMAAP_MR_IP=${DMAAP_MR_IP}
echo KAFKA_IP=${KAFKA_IP}
echo ZOOKEEPER_IP=${ZOOKEEPER_IP}

# Shutdown DMAAP Container
docker kill $DMAAP

# Initial docker-compose up and down is for populating kafka and zookeeper IPs in /var/tmp/MsgRtrApi.properites
sed -i -e '/config.zk.servers=/ s/=.*/='$ZOOKEEPER_IP'/' /var/tmp/MsgRtrApi.properties
sed -i -e '/kafka.metadata.broker.list=/ s/=.*/='$KAFKA_IP':9092/' /var/tmp/MsgRtrApi.properties

# Start DMaaP MR containers with docker compose and configuration from docker-compose.yml
docker-compose build
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d
sleep 5

export VESC_IP=${VESC_IP}
export HOST_IP=${HOST_IP}
export DMAAP_MR_IP=${DMAAP_MR_IP}
#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DR_PROV_IP:${DR_PROV_IP} -v DR_NODE_IP:${DR_NODE_IP} -v DMAAP_MR_IP:${DMAAP_MR_IP} -v VESC_IP:${VESC_IP}"

pip install jsonschema uuid
# Wait container ready
sleep 2