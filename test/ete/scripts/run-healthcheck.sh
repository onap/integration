#!/bin/bash -x

SSH_KEY=~/.ssh/onap_key

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh

cd $WORKSPACE/test/ete/scripts

ROBOT_IP=$(./get-floating-ip.sh onap-robot)
echo "ROBOT_IP=${ROBOT_IP}"

if [ "" == "${ROBOT_IP}" ]; then
    exit 1
fi

ssh-keygen -R ${ROBOT_IP}

set +x
timeout 15m ssh -o StrictHostKeychecking=no -i ${SSH_KEY} root@${ROBOT_IP} "OS_PROJECT_ID=$OS_PROJECT_ID OS_USERNAME=$OS_USERNAME OS_PASSWORD=$OS_PASSWORD bash -s" < ./remote/run-robot.sh
RESULT=$?
set -x

LOG_DIR=$(ssh -i ${SSH_KEY} root@${ROBOT_IP} "ls -1t /opt/eteshare/logs | grep health | head -1")
echo "Browse Robot results at http://${ROBOT_IP}:88/logs/${LOG_DIR}/"
rsync -e "ssh -i ${SSH_KEY}" -avtz root@${ROBOT_IP}:/opt/eteshare/logs/${LOG_DIR}/ $WORKSPACE/archives/
exit $RESULT
