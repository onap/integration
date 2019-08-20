#!/bin/bash

if [ $# -ne 1 ] || [ ! -f $1 ]; then
    echo file not found
    exit 1
fi

PODS_FILE=$1
DIR=$(dirname "$(readlink -f "$PODS_FILE")")
JOB=$(basename $DIR)
echo $JOB
for POD_TO_DELETE in $(cat $PODS_FILE); do
    echo build "$JOB $POD_TO_DELETE"
    java -jar ~/jenkins-cli.jar  -s http://localhost:8080/jenkins -auth jenkins:g2jenkins build $JOB -p POD_TO_DELETE=$POD_TO_DELETE
done
