#!/bin/bash

SSH_KEY=~/.ssh/onap_key

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh

cd $WORKSPACE/test/ete/scripts

ROBOT_IP=$(./get-floating-ip.sh onap-robot)
echo "ROBOT_IP=${ROBOT_IP}"

# allow direct login as root
ssh -o StrictHostKeychecking=no -i ${SSH_KEY} ubuntu@${ROBOT_IP} 'sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/'

ssh -o StrictHostKeychecking=no -i ${SSH_KEY} root@${ROBOT_IP} "OS_PASSWORD_INPUT=$OS_PASSWORD_INPUT bash -s" < ./remote/run-robot.sh
LOG_DIR=$(ssh -o StrictHostKeychecking=no -i ${SSH_KEY} root@${ROBOT_IP} "ls -1t /opt/eteshare/logs | head -1")
echo "Browse Robot results at http://${ROBOT_IP}:88/logs/${LOG_DIR}/"
rsync -e "ssh -i ${SSH_KEY}" -avPz root@${ROBOT_IP}:/opt/eteshare/logs/${LOG_DIR}/ $WORKSPACE/archives/
