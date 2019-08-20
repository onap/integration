#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "$0 <job> <start_build> <end_build>"
    exit 1
fi
JOB_NAME=$1
START_BUILD=$2
END_BUILD=$3

set -x
for BUILD_NUMBER in $(seq $START_BUILD $END_BUILD); do
    ./process-robot.sh ~/jobs/$JOB_NAME/builds/$BUILD_NUMBER/robot-plugin/output.xml $JOB_NAME $BUILD_NUMBER
done
