#!/bin/bash
echo "Starting teardown script"
kill-instance.sh vesc
kill-instance.sh dockercompose_dmaap_1
kill-instance.sh dockercompose_kafka_1
kill-instance.sh dockercompose_zookeeper_1


