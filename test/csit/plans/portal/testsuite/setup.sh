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
git clone http://gerrit.onap.org/r/portal

# Refresh configuration and scripts
cd portal
git pull
cd deliveries
rm .env
#rm docker-compose.yml
cp $CURR/.env .
#cp $CURR/docker-compose.yml .
#cd  properties_rackspace/ECOMPPORTALAPP
#rm  system.properties
#cp  $CURR/system.properties .
#cd ../..
# Get image names used below from docker-compose environment file
source $CURR/.env

# Copy property files to new directory
mkdir -p $PROPS_DIR
cp -r properties_rackspace/* $PROPS_DIR
# Also create logs directory
mkdir -p $LOGS_DIR


# Refresh images
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO
docker pull $NEXUS_DOCKER_REPO/openecomp/${DB_IMG_NAME}:$DOCKER_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/openecomp/${EP_IMG_NAME}:$DOCKER_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/openecomp/${WMS_IMG_NAME}:$DOCKER_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/$CLI_IMG_NAME:$CLI_DOCKER_VERSION

# Tag them as expected by docker-compose file
docker tag $NEXUS_DOCKER_REPO/openecomp/${DB_IMG_NAME}:$DOCKER_IMAGE_VERSION $DB_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/openecomp/${EP_IMG_NAME}:$DOCKER_IMAGE_VERSION $EP_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/openecomp/${WMS_IMG_NAME}:$DOCKER_IMAGE_VERSION $WMS_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/$CLI_IMG_NAME:$CLI_DOCKER_VERSION $CLI_IMG_NAME:$PORTAL_TAG

# compose is not in /usr/bin
docker-compose down
docker-compose up -d

#${HOSTNAME}="portal.api.simpledemo.openecomp.org"
#echo "$HOST_IP ${HOSTNAME}" >> /etc/hosts

#echo "$HOST_IP portal.api.simpledemo.openecomp.org" >> /etc/hosts
#sudo sed -i "2i$HOST_IP  portal.api.simpledemo.openecomp.org"   /etc/hosts

HOST="portal.api.simpledemo.openecomp.org"
sed -i "/$HOST/ s/.*/$HOST_IP\t$HOST/g" /etc/hosts


# WAIT 5 minutes maximum and test every 5 seconds if Portal up using HealthCheck API
TIME_OUT=300
INTERVAL=20
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost:8989/ECOMPPORTAL/portalApi/healthCheck); echo $response

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





