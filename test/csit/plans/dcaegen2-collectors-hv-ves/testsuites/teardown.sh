#!/usr/bin/env bash

cd ssl
make clean
cd ..

COMPOSE_LOGS_FILE=${WORKSPACE}/archives/containers_logs/docker-compose.log
docker-compose logs > ${COMPOSE_LOGS_FILE}
docker-compose down
docker-compose rm -f

docker network rm ${CONTAINERS_NETWORK}

if grep "LEAK:" ${COMPOSE_LOGS_FILE}; then
    echo "Teardown failed. Memory leak detected in docker-compose logs."
    exit 1
fi
