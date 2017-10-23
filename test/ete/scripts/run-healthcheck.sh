#!/bin/bash

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

cd $WORKSPACE/test/ete/scripts

ROBOT_IP=$(./get-floating-ip.sh onap-robot)
echo "ROBOT_IP=${ROBOT_IP}"

ssh -o StrictHostKeychecking=no -i ~/.ssh/onap_key root@${ROBOT_IP} "OS_PASSWORD_INPUT=$OS_PASSWORD_INPUT bash -s" < ./remote/run-robot.sh
