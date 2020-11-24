#!/bin/bash

echo "======= docker ps"
docker ps

echo "======= Docker image cache"
docker images nexus3.onap.org:10003/onap/masspnf-simulator

export NUM_OF_SIMS=`find pnf-sim-lw* -maxdepth 0 | wc -l`
echo $NUM_OF_SIMS

if [ "$NUM_OF_SIMS" -gt 0 ];
then
	echo "======= docker-compose, first instance"
	cat pnf-sim-lw-0/docker-compose.yml
	
	echo "======= Java config.yml, first instance"
	cat pnf-sim-lw-0/config/config.yml
fi

if (("$NUM_OF_SIMS" > 2));
then
	echo "======= docker-compose, last instance"
	cat pnf-sim-lw-$(($NUM_OF_SIMS-1))/docker-compose.yml
	
	echo "======= Java config.yml, last instance"
	cat pnf-sim-lw-$(($NUM_OF_SIMS-1))/config/config.yml
fi


