#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP DMAAP MR 
# ================================================================================
# Copyright (C) 2018 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#
# This script is a copy of plans/dmaap/mrpubsub/setup.sh, placed in the scripts
# dir, and edited to be a callable function from other plans. e.g. dmaap-buscontroller needs it.
#
source ${SCRIPTS}/common_functions.sh

# function to launch DMaaP MR docker containers.
# sets global var IP with assigned IP address of MR container.
# (kafka and zk containers are not called externally)

function dmaap_mr_launch() {
		#
		# the default prefix for docker containers is the directory name containing the docker-compose.yml file.
		# It can be over-written by an env variable COMPOSE_PROJECT_NAME.  This env var seems to be set in the Jenkins CSIT environment
		COMPOSE_PREFIX=${COMPOSE_PROJECT_NAME:-docker-compose}
		echo "COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME"
		echo "COMPOSE_PREFIX=$COMPOSE_PREFIX"

		# Clone DMaaP Message Router repo
		mkdir -p $WORKSPACE/archives/dmaapmr
		cd $WORKSPACE/archives/dmaapmr
		#unset http_proxy https_proxy
		git clone --depth 1 http://gerrit.onap.org/r/dmaap/messagerouter/messageservice -b master
		cd messageservice
		git pull
		cd $WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose
		cp $WORKSPACE/archives/dmaapmr/messageservice/bundleconfig-local/etc/appprops/MsgRtrApi.properties /var/tmp/


		# start DMaaP MR containers with docker compose and configuration from docker-compose.yml
		docker login -u docker -p docker nexus3.onap.org:10001
		docker-compose up -d
		docker ps

		# Wait for initialization of Docker contaienr for DMaaP MR, Kafka and Zookeeper
		for i in {1..50}; do
			if [ $(docker inspect --format '{{ .State.Running }}' ${COMPOSE_PREFIX}_dmaap_1) ] && \
				[ $(docker inspect --format '{{ .State.Running }}' ${COMPOSE_PREFIX}_zookeeper_1) ] && \
				[ $(docker inspect --format '{{ .State.Running }}' ${COMPOSE_PREFIX}_dmaap_1) ] 
			then
				echo "DMaaP Service Running"	
				break    		
			else 
				echo sleep $i		
				sleep $i
			fi
		done


		DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${COMPOSE_PREFIX}_dmaap_1)
		IP=${DMAAP_MR_IP}
		KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${COMPOSE_PREFIX}_kafka_1)
		ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${COMPOSE_PREFIX}_zookeeper_1)

		echo DMAAP_MR_IP=${DMAAP_MR_IP}
		echo IP=${IP}
		echo KAFKA_IP=${KAFKA_IP}
		echo ZOOKEEPER_IP=${ZOOKEEPER_IP}

		# Initial docker-compose up and down is for populating kafka and zookeeper IPs in /var/tmp/MsgRtrApi.properites
		docker-compose down 

		# Update kafkfa and zookeeper properties in MsgRtrApi.propeties which will be copied to DMaaP Container
		sed -i -e 's/<zookeeper_host>/'$ZOOKEEPER_IP'/' /var/tmp/MsgRtrApi.properties
		sed -i -e 's/<kafka_host>:<kafka_port>/'$KAFKA_IP':9092/' /var/tmp/MsgRtrApi.properties

		docker-compose build
		docker login -u docker -p docker nexus3.onap.org:10001
		docker-compose up -d 

		# Wait for initialization of Docker containers
		for i in {1..50}; do
				if [ $(docker inspect --format '{{ .State.Running }}' ${COMPOSE_PREFIX}_dmaap_1) ] && \
						[ $(docker inspect --format '{{ .State.Running }}' ${COMPOSE_PREFIX}_zookeeper_1) ] && \
						[ $(docker inspect --format '{{ .State.Running }}' ${COMPOSE_PREFIX}_dmaap_1) ]
				then
						echo "DMaaP Service Running"
						break
				else
						echo sleep $i
						sleep $i
				fi
		done

		# Wait for initialization of docker services
		for i in {1..50}; do
			curl -sS -m 1 ${DMAAP_MR_IP}:3904/events/TestTopic && break 
			echo sleep $i
			sleep $i
		done
}

