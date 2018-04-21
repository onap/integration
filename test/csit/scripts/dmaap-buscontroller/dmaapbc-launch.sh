#!/bin/bash

# script to launch DMaaP buscontroller docker container
# sets global var IP with assigned IP address

function dmaapbc_launch() {
	TAG="nexus3.onap.org:10001/onap/dmaap/buscontroller"
	CONTAINER_NAME=dmaapbc
	IP=""

	cd ${WORKSPACE}/test/csit/scripts/dmaap-buscontroller

	TMP_CFG=/tmp/docker-databus-controller.conf
	. ./onapCSIT.env > $TMP_CFG
	docker run -d --name $CONTAINER_NAME -v $TMP_CFG:/opt/app/config/conf $TAG
	IP=`get-instance-ip.sh ${CONTAINER_NAME}`

	# Wait for initialization
	for i in {1..10}; do
    	curl -sS ${IP}:8080 && break
    	echo sleep $i
    	sleep $i
	done

}
