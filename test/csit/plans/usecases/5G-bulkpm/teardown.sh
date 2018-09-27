#!/bin/bash
echo "Starting teardown script"
kill-instance.sh $DMAAP
kill-instance.sh $KAFKA
kill-instance.sh $ZOOKEEPER
kill-instance.sh vescollector
kill-instance.sh datarouter-node
kill-instance.sh datarouter-prov
kill-instance.sh fileconsumer-node
kill-instance.sh mariadb
kill-instance.sh dfc
kill-instance.sh sftp