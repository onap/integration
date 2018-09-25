#!/bin/bash
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

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
KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $KAFKA)
ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ZOOKEEPER)
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DMAAP)

sleep 2
# Shutdown DMAAP Container
docker kill $DMAAP

# Initial docker-compose up and down is for populating kafka and zookeeper IPs in /var/tmp/MsgRtrApi.properites
sed -i -e '/config.zk.servers=/ s/=.*/='$ZOOKEEPER_IP'/' /var/tmp/MsgRtrApi.properties
sed -i -e '/kafka.metadata.broker.list=/ s/=.*/='$KAFKA_IP':9092/' /var/tmp/MsgRtrApi.properties

# Start DMaaP MR containers with docker compose and configuration from docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d
sleep 5

# Clone DMaaP Data Router repo
mkdir -p $WORKSPACE/archives/dmaapdr
cd $WORKSPACE/archives/dmaapdr
git clone --depth 1 https://gerrit.onap.org/r/dmaap/datarouter -b master
cd datarouter
cd $WORKSPACE/archives/dmaapdr/datarouter/docker-compose/
rm -rf docker-compose.yml
cp $WORKSPACE/test/csit/plans/dcae-bulkpm/bulkpm-suite/composefile/docker-compose-e2e.yml $WORKSPACE/archives/dmaapdr/datarouter/docker-compose/docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d
docker kill datarouter-prov
docker kill datarouter-node
docker kill vescollector
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
sed -i -e '/DMAAPHOST:/ s/:.*/: '$HOST_IP'/' docker-compose.yml
MARIADB=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb )
sed -i 's/172.100.0.2/'$MARIADB'/g' $WORKSPACE/archives/dmaapdr/datarouter/docker-compose/prov_data/provserver.properties
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

sleep 5

# Get IP address of datarrouger-prov, datarouter-node, fileconsumer-node.
DR_PROV_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-prov)
DR_NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-node)
DR_SUBSCIBER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' fileconsumer-node)
DR_GATEWAY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' datarouter-prov)

echo DR_PROV_IP=${DR_PROV_IP}
echo DR_NODE_IP=${DR_NODE_IP}
echo DR_GATEWAY_IP=${DR_GATEWAY_IP}
echo DR_SUBSCIBER_IP=${DR_SUBSCIBER_IP}

docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/NODES?val=dmaap-dr-node\|$DR_GATEWAY_IP"
docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"
docker exec datarouter-prov /bin/sh -c "echo '${DR_NODE_IP}' dmaap-dr-node >> /etc/hosts"
docker exec datarouter-node /bin/sh -c "echo '${DR_PROV_IP}' dmaap-dr-prov >> /etc/hosts"
docker exec datarouter-node /bin/sh -c "echo '${DR_SUBSCIBER_IP}' dmaap-dr-subscriber >> /etc/hosts"

# Get IP address of DMAAP, KAFKA, Zookeeper
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DMAAP)
KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $KAFKA)
ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ZOOKEEPER)
VESC_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vescollector)
SFTP_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sftp)

export VESC_IP=${VESC_IP}
export HOST_IP=${HOST_IP}
export DMAAP_MR_IP=${DMAAP_MR_IP}

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DR_PROV_IP:${DR_PROV_IP} -v DR_NODE_IP:${DR_NODE_IP} -v DMAAP_MR_IP:${DMAAP_MR_IP} -v VESC_IP:${VESC_IP} -v DR_SUBSCIBER_IP:${DR_SUBSCIBER_IP}"

pip install jsonschema uuid
# Wait container ready
sleep 2

# Data File Collector configuration :
cp $WORKSPACE/test/csit/plans/dcae-bulkpm/bulkpm-suite/assets/datafile_endpoints.json /tmp/
sed -i 's/dmaapmrhost/'${DMAAP_MR_IP}'/g' /tmp/datafile_endpoints.json
sed -i 's/dmaapdrhost/'${DR_PROV_IP}'/g' /tmp/datafile_endpoints.json
docker cp /tmp/datafile_endpoints.json dfc:/config/
docker restart dfc

# SFTP Configuration:
# Update the File Ready Notification with actual sftp ip address and copy pm files to sftp server.
cp $WORKSPACE/test/csit/tests/dcae-bulkpm/testcases/assets/json_events/FileExistNotification.json $WORKSPACE/test/csit/tests/dcae-bulkpm/testcases/assets/json_events/FileExistNotificationUpdated.json
sed -i 's/sftpserver/'${SFTP_IP}'/g' $WORKSPACE/test/csit/tests/dcae-bulkpm/testcases/assets/json_events/FileExistNotificationUpdated.json
docker cp $WORKSPACE/test/csit/plans/dcae-bulkpm/bulkpm-suite/assets/xNF.pm.xml.gz sftp:/home/admin/

# Data Router Configuration:
# Create default feed and create file consumer subscriber on data router
curl -v -X POST -H "Content-Type:application/vnd.att-dr.feed" -H "X-ATT-DR-ON-BEHALF-OF:dradmin" --data-ascii @$WORKSPACE/test/csit/plans/dcae-bulkpm/bulkpm-suite/assets/createFeed.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443
cp $WORKSPACE/test/csit/plans/dcae-bulkpm/bulkpm-suite/assets/addSubscriber.json /tmp/addSubscriber.json
sed -i 's/fileconsumer/'${DR_SUBSCIBER_IP}'/g' /tmp/addSubscriber.json
curl -v -X POST -H "Content-Type:application/vnd.att-dr.subscription" -H "X-ATT-DR-ON-BEHALF-OF:dradmin" --data-ascii @/tmp/addSubscriber.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443/subscribe/1