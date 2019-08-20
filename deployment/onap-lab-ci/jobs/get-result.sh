#!/bin/bash

JOB=$1
BUILD=$2

mkdir -p $JOB
JSON=$JOB/$BUILD.json
if [ ! -f $JSON ]; then
    curl -s "http://localhost:8080/jenkins/job/$JOB/$BUILD/api/json" > $JSON
fi

POD_TO_DELETE=$(jq -r '.actions[] | select(._class == "hudson.model.ParametersAction") | .parameters[] | select(._class == "hudson.model.StringParameterValue") | .value' < $JSON)

TIMESTAMP=$(jq '.timestamp' < $JSON)
START_TIME=$(date -d @$(($TIMESTAMP/1000)) +%H:%M:%S)

DURATION=$(jq '.duration' < $JSON)
DURATION_TIME=$(date -ud @$(($DURATION/1000)) +%M:%S)

RESULT=$(jq -r '.result' < $JSON)

echo "|$POD_TO_DELETE|$START_TIME|$DURATION_TIME|$RESULT|[$BUILD|http://onapci.org/logs/$JOB/$BUILD/]|"
