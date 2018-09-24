#!/bin/bash
echo "Starting teardown script"
cd $WORKSPACE/test/csit/scripts
./kill-instance.sh $DMAAP
./kill-instance.sh $KAFKA
./kill-instance.sh $ZOOKEEPER
./kill-instance.sh vescollector
./kill-instance.sh datarouter-node
./kill-instance.sh datarouter-prov
./kill-instance.sh subscriber-node
./kill-instance.sh mariadb
./kill-instance.sh dfc
./kill-instance.sh sftp
sudo sed -i '/dmaap/d' /etc/hosts
sudo set -i '/fileconsumer/d' /etc/hosts