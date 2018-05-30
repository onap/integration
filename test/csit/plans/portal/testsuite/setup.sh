#!/bin/bash
# Starts docker containers for ONAP Portal
# This version for Amsterdam/R1 of Portal, uses docker-compose.
# Temporarily maintained in portal/deliveries area;
# replicated from the ONAP demo/boot area due to release concerns.

# Start Xvfb
echo -e "Starting Xvfb on display ${DISPLAY} with res ${RES}"
Xvfb ${DISPLAY} -ac -screen 0 ${RES} +extension RANDR &
XVFBPID=$!
# Get pid of this spawned process to make sure we kill the correct process later

#Get current IP of VM
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
export HOST_IP=${HOST_IP}



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


# Pass any variables required by Robot test suites in ROBOT_VARIABLES
#ROBOT_VARIABLES="-v MOCK_IP:${MOCK_IP} -v IP:${IP} -v POLICY_IP:${POLICY_IP} -v DOCKER_IP:${DOCKER_IP}"
#export PORTAL_IP=${PORTAL_IP}
ROBOT_VARIABLES="-v MOCK_IP:${MOCK_IP} -v IP:${IP}  -v DOCKER_IP:${DOCKER_IP}"
export DOCKER_IP=${DOCKER_IP}




# be verbose
set -x

# Establish environment variables
NEXUS_USERNAME=docker
NEXUS_PASSWD=docker
NEXUS_DOCKER_REPO=nexus3.onap.org:10003



CURR="$(pwd)"
git clone http://gerrit.onap.org/r/portal -b "beijing"

# Refresh configuration and scripts
cd portal
git pull
cd deliveries
rm .env
rm docker-compose.yml
cp $CURR/.env .
cp $CURR/docker-compose.yml .
#cd  properties_simpledemo/ECOMPPORTALAPP
#rm  system.properties
#cp  $CURR/system.properties .
#cd ../..
# Get image names used below from docker-compose environment file
source $CURR/.env
#source .env

# Make inter-app communication work in CSIT
export EXTRA_HOST_IP="-i ${HOST_IP}"
export EXTRA_HOST_NAME="-n portal.api.simpledemo.onap.org"


# Copy property files to new directory
mkdir -p $PROPS_DIR
cp -r properties_simpledemo/* $PROPS_DIR
cp $CURR/web.xml $PROPS_DIR/ONAPPORTAL
cp $CURR/logback.xml $PROPS_DIR/ONAPPORTAL
cp $CURR/cache.ccf $PROPS_DIR/ONAPPORTAL
cp $CURR/portal.properties $PROPS_DIR/ONAPPORTAL
# Also create logs directory
mkdir -p $LOGS_DIR


# Refresh images
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO
docker pull $NEXUS_DOCKER_REPO/$DB_IMG_NAME:$DOCKER_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/$EP_IMG_NAME:$DOCKER_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/$SDK_IMG_NAME:$DOCKER_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/$CDR_IMG_NAME:$CDR_IMAGE_VERSION
docker pull $ZK_IMG_NAME:$ZK_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/$WMS_IMG_NAME:$DOCKER_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/$CLI_IMG_NAME:$CLI_DOCKER_VERSION

# Tag them as expected by docker-compose file
docker tag $NEXUS_DOCKER_REPO/$DB_IMG_NAME:$DOCKER_IMAGE_VERSION $DB_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/$EP_IMG_NAME:$DOCKER_IMAGE_VERSION $EP_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/$SDK_IMG_NAME:$DOCKER_IMAGE_VERSION $SDK_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/$CDR_IMG_NAME:$CDR_IMAGE_VERSION $CDR_IMG_NAME:$PORTAL_TAG
docker tag $ZK_IMG_NAME:$ZK_IMAGE_VERSION $ZK_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/$WMS_IMG_NAME:$DOCKER_IMAGE_VERSION $WMS_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/$CLI_IMG_NAME:$CLI_DOCKER_VERSION $CLI_IMG_NAME:$PORTAL_TAG


# compose is not in /usr/bin
docker-compose down
docker-compose up -d

#${HOSTNAME}="portal.api.simpledemo.openecomp.org"
#echo "$HOST_IP ${HOSTNAME}" >> /etc/hosts

#echo "$HOST_IP portal.api.simpledemo.openecomp.org" >> /etc/hosts
#sudo sed -i "2i$HOST_IP  portal.api.simpledemo.openecomp.org"   /etc/hosts

#HOST="portal.api.simpledemo.openecomp.org"
#sudo sed -i "/$HOST/ s/.*/$HOST_IP\t$HOST/g" /etc/hosts

# insert/update hosts entry
ip_address=$HOST_IP
host_name="portal.api.simpledemo.onap.org"
# find existing instances in the host file and save the line numbers
matches_in_hosts="$(grep -n $host_name /etc/hosts | cut -f1 -d:)"
host_entry="${ip_address} ${host_name}"

echo "$host_entry"

if [ ! -z "$matches_in_hosts" ]
then
echo "Updating existing hosts entry."
# iterate over the line numbers on which matches were found
while read -r line_number; do
# replace the text of each line with the desired host entry
sudo sed -i '' "${line_number}s/.*/${host_entry} /" /etc/hosts
echo "${line_number}   ${host_entry}"
done <<< "$matches_in_hosts"
else
echo "Adding new hosts entry."
echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null
fi



sleep 6m

# WAIT 5 minutes maximum and test every 5 seconds if Portal up using HealthCheck API
TIME_OUT=500
INTERVAL=20
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://portal.api.simpledemo.onap.org:8989/ONAPPORTAL/portalApi/healthCheck); echo $response

  if [ "$response" == "200" ]; then
    echo Portal and its database well started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if Portal is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for tests...
fi

#sleep 3m



#if [ "$TIME" -ge "$TIME_OUT" ]; then
#   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for tests...
#fi





#Get current IP of VM
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
export HOST_IP=${HOST_IP}

docker logs deliveries_portal-db_1
docker logs deliveries_portal-app_1
docker logs deliveries_portal-sdk_1
docker logs deliveries_portal-wms_1


tail -500 $LOGS_DIR/onapportal/error.log
cat $LOGS_DIR/onapportal/application.log
tail -500 $LOGS_DIR/onapportal/debug.log

