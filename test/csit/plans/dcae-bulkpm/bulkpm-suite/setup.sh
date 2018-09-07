#!/bin/bash
# Place the scripts in run order:
#Make sure python-uuid is installed

# Place the scripts in run order:
source ${SCRIPTS}/dcae-bulkpm/xNFSimulator.sh

# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

#get current host IP addres
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')

VESC_IMAGE=nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.ves.vescollector:1.3.1
echo VESC_IMAGE=${VESC_IMAGE}

# Start DCAE VES Collector
docker run -d -p 8080:8080/tcp -p 8443:8443/tcp -P --name vesc -e DMAAPHOST=${HOST_IP} ${VESC_IMAGE}

# Clone DMaaP Message Router repo
mkdir -p $WORKSPACE/archives/dmaapmr
cd $WORKSPACE/archives/dmaapmr
#unset http_proxy https_proxy
git clone --depth 1 http://gerrit.onap.org/r/dmaap/messagerouter/messageservice -b master
git pull
cd $WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose
cp $WORKSPACE/archives/dmaapmr/messageservice/bundleconfig-local/etc/appprops/MsgRtrApi.properties /var/tmp/

# Update kafkfa and zookeeper properties in MsgRtrApi.propeties which will be copied to DMaaP Container
sed -i -e 's#nexus3.onap.org:10001/onap/dmaap/kafka01101:0.0.1#wurstmeister/kafka:1.1.0#' $WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose/docker-compose.yml

# start DMaaP MR containers with docker compose and configuration from docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d

# Wait for initialization of Docker contaienr for DMaaP MR, Kafka and Zookeeper
for i in {1..50}; do
if [ $(docker inspect --format '{{ .State.Running }}' dockercompose_kafka_1) ] && \
[ $(docker inspect --format '{{ .State.Running }}' dockercompose_zookeeper_1) ] && \
[ $(docker inspect --format '{{ .State.Running }}' dockercompose_dmaap_1) ]
then
   echo "DMaaP Service Running"
   break
else
   echo sleep $i
   sleep $i
fi
done

# Get IP address of DMAAP, KAFKA, Zookeeper
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_dmaap_1)
KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_kafka_1)
ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_zookeeper_1)

echo DMAAP_MR_IP=${DMAAP_MR_IP}
echo KAFKA_IP=${KAFKA_IP}
echo ZOOKEEPER_IP=${ZOOKEEPER_IP}

# Shutdown DMAAP Container
docker kill dockercompose_dmaap_1

# Initial docker-compose up and down is for populating kafka and zookeeper IPs in /var/tmp/MsgRtrApi.properites
sed -i -e '/config.zk.servers=/ s/=.*/='$ZOOKEEPER_IP'/' /var/tmp/MsgRtrApi.properties
sed -i -e '/kafka.metadata.broker.list=/ s/=.*/='$KAFKA_IP':9092/' /var/tmp/MsgRtrApi.properties

# Start DMaaP MR containers with docker compose and configuration from docker-compose.yml
docker-compose build
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d
sleep 5

# Get IP address of DMAAP, KAFKA, Zookeeper and VESC
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_dmaap_1)
KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_kafka_1)
ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_zookeeper_1)

VESC_IP=`get-instance-ip.sh vesc`
export VESC_IP=${VESC_IP}
export HOST_IP=${HOST_IP}
export DMAAP_MR_IP=${DMAAP_MR_IP}

ROBOT_VARIABLES="-v DMAAP_MR_IP:${DMAAP_MR_IP} -v VESC_IP:${VESC_IP}"

pip install jsonschema uuid
# Wait container ready
sleep 2
