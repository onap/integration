#!/bin/bash

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh

# Delete all existing stacks
STACKS=$(openstack stack list -c "Stack Name" -f value)
if [ ! -z "${STACKS}" ]; then
    echo "Deleting Stacks ${STACKS}"
    openstack stack delete -y $STACKS
else
    echo "No existing stacks to delete."
fi

STACK="ete-$(uuidgen | cut -c-8)"
echo "New Stack Name: ${STACK}"


cp ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.env ${WORKSPACE}/test/ete/labs/windriver/onap-openstack-demo.env
envsubst < ${WORKSPACE}/test/ete/labs/windriver/onap-openstack-template.env > ${WORKSPACE}/test/ete/labs/windriver/onap-openstack.env

openstack stack create -t ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.yaml -e ${WORKSPACE}/test/ete/labs/windriver/onap-openstack.env $STACK

