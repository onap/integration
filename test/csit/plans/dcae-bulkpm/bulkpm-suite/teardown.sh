#!/bin/bash
echo "Starting teardown script"
kill-instance.sh vesc
cd $WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose
docker-compose down -v
cd $WORKSPACE/archives/dmaapdr/datarouter/docker-compose/
docker-compose down -v
sed -i '/dmaap/d' /etc/hosts