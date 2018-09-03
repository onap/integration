#!/usr/bin/env bash

cd ssl
make clean
cd ..

docker-compose logs > ${WORKSPACE}/archives/containers_logs/docker-compose.log
docker-compose down
docker-compose rm -f

docker network rm ${CONTAINERS_NETWORK}