#!/bin/bash -x

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh

# Delete all existing stacks
STACKS=$(openstack stack list -c "Stack Name" -f value)

if [ ! -z "${STACKS}" ]; then
    echo "Deleting Stacks ${STACKS}"
    openstack stack delete -y $STACKS
    for STACK in ${STACKS}; do
        until [ "DELETE_IN_PROGRESS" != "$(openstack stack show -c stack_status -f value $STACK)" ]; do
            sleep 30
        done
    done
else
    echo "No existing stacks to delete."
fi




STACK="ete-$(uuidgen | cut -c-8)"
echo "New Stack Name: ${STACK}"


cp ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.env ${WORKSPACE}/test/ete/labs/windriver/onap-openstack-demo.env
envsubst < ${WORKSPACE}/test/ete/labs/windriver/onap-openstack-template.env > ${WORKSPACE}/test/ete/labs/windriver/onap-openstack.env
#diff ${WORKSPACE}/test/ete/labs/windriver/onap-openstack-template.env ${WORKSPACE}/test/ete/labs/windriver/onap-openstack.env

openstack stack create -t ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.yaml -e ${WORKSPACE}/test/ete/labs/windriver/onap-openstack.env $STACK

while [ "CREATE_IN_PROGRESS" == "$(openstack stack show -c stack_status -f value $STACK)" ]; do
    sleep 15
done

STATUS=$(openstack stack show -c stack_status -f value $STACK)
echo $STATUS
if [ "CREATE_COMPLETE" != "$STATUS" ]; then
    exit 1
fi


# wait until Robot VM initializes
ROBOT_IP=$(./get-floating-ip.sh onap-robot)
echo "ROBOT_IP=${ROBOT_IP}"

if [ "" == "${ROBOT_IP}" ]; then
    exit 1
fi

ssh-keygen -R ${ROBOT_IP}

SSH_KEY=~/.ssh/onap_key

until ssh -o StrictHostKeychecking=no -i ${SSH_KEY} root@${ROBOT_IP} "docker ps | grep -q openecompete_container"
do
      sleep 1m
done
