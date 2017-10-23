#!/bin/bash

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh

# Delete all existing stacks
STACKS=$(openstack stack list -c "Stack Name" -f value)
echo "Deleting Stacks ${STACKS}"
openstack stack delete -y $STACKS

STACK="ete-$(uuidgen | cut -c-8)"
echo "New Stack Name: ${STACK}"
openstack stack create -t ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.yaml -e ${WORKSPACE}/test/ete/labs/windriver/onap-openstack.env $STACK

