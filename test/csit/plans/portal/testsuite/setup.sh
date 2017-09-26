#!/bin/bash
# Starts docker containers for ONAP Portal
# This version for Amsterdam/R1 of Portal, uses docker-compose.
# Temporarily maintained in portal/deliveries area;
# replicated from the ONAP demo/boot area due to release concerns.

#Get current IP of VM
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
export HOST_IP=${HOST_IP}


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

# Get image names used below from docker-compose environment file
source $CURR/.env

# Copy property files
ETC=/PROJECT/OpenSource/UbuntuEP/etc
mkdir -p $ETC
cp -r properties_rackspace/* $ETC

# Refresh images
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO
docker pull $NEXUS_DOCKER_REPO/openecomp/${DB_IMG_NAME}:$DOCKER_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/openecomp/${EP_IMG_NAME}:$DOCKER_IMAGE_VERSION
docker pull $NEXUS_DOCKER_REPO/openecomp/${WMS_IMG_NAME}:$DOCKER_IMAGE_VERSION

# Tag them as expected by docker-compose file
docker tag $NEXUS_DOCKER_REPO/openecomp/${DB_IMG_NAME}:$DOCKER_IMAGE_VERSION $DB_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/openecomp/${EP_IMG_NAME}:$DOCKER_IMAGE_VERSION $EP_IMG_NAME:$PORTAL_TAG
docker tag $NEXUS_DOCKER_REPO/openecomp/${WMS_IMG_NAME}:$DOCKER_IMAGE_VERSION $WMS_IMG_NAME:$PORTAL_TAG

# compose is not in /usr/bin
docker-compose down
docker-compose up -d

#Get current IP of VM
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
export HOST_IP=${HOST_IP}



