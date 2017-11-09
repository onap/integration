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
        until ! openstack stack show -c stack_status -f value $STACK; do
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
diff ${WORKSPACE}/test/ete/labs/windriver/onap-openstack-template.env ${WORKSPACE}/test/ete/labs/windriver/onap-openstack.env

openstack stack create -t ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.yaml -e ${WORKSPACE}/test/ete/labs/windriver/onap-openstack.env $STACK

while [ "CREATE_IN_PROGRESS" == "$(openstack stack show -c stack_status -f value $STACK)" ]; do
    sleep 10
done

STATUS=$(openstack stack show -c stack_status -f value $STACK)
echo $STATUS
[ "CREATE_COMPLETE" == "$STATUS" ]
