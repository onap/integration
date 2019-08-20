#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "$0 <onap-pods.json> <job> <build>"
    exit 1
fi
JSON_OUTPUT=$1
JOB=$2
BUILD=$3

INFLUX_ENDPOINT='http://10.145.123.16:8086/write?db=robot'


TIME=$(date -r $JSON_OUTPUT +%s%N)

POINTS_FILE=/tmp/points-$JOB-$BUILD-pods.txt
rm -f $POINTS_FILE

cat $JSON_OUTPUT | jq -r  '.items[] | ( (.status.containerStatuses[] | ( " "+.image + " " + (.restartCount | tostring) + " " + (.ready | tostring) ) ) ) + " " + .metadata.name ' | grep -e 'onap/' -e 'openecomp/' | sort | while read CONTAINER; do
    IMAGE=$(echo $CONTAINER | cut -d ' ' -f 1 | sed -r 's#.*/(onap|openecomp)/##g')
    RESTART_COUNT=$(echo $CONTAINER | cut -d ' ' -f 2)
    READY=$(echo $CONTAINER | cut -d ' ' -f 3)
    POD=$(echo $CONTAINER | cut -d ' ' -f 4)

    if [ "$READY" = "true" ] && [ "$RESTART_COUNT" -eq 0 ]; then
        PASS=1
        FAIL=0
    else
        PASS=0
        FAIL=1
    fi

    # currently assumes that no onap pod contains multiple containers of with the same image
    echo container,job=$JOB,image=$IMAGE,pod=$POD build=$BUILD,restartCount=$RESTART_COUNT,ready=$READY,pass=$PASS,fail=$FAIL $TIME | tee -a $POINTS_FILE
done

curl -i $INFLUX_ENDPOINT --data-binary @$POINTS_FILE
